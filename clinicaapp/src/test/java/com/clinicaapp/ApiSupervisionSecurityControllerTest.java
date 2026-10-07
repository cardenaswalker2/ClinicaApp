package com.clinicaapp;

import com.clinicaapp.controller.rest.ApiSupervisionController;
import com.clinicaapp.model.AuditoriaSupervision;
import com.clinicaapp.model.MensajeDirecto;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IMensajeDirectoService;
import com.clinicaapp.service.IUsuarioSupervisionService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
public class ApiSupervisionSecurityControllerTest {

    @Mock
    private IUsuarioSupervisionService supervisionService;

    @Mock
    private IMensajeDirectoService mensajeDirectoService;

    @Mock
    private UsuarioRepository usuarioRepo;

    @InjectMocks
    private ApiSupervisionController controller;

    private Usuario adminUser;
    private Usuario regularUser;
    private MockHttpServletRequest request;

    @BeforeEach
    void setUp() {
        request = new MockHttpServletRequest();

        adminUser = new Usuario();
        adminUser.setId("admin_1");
        adminUser.setEmail("superadmin@clinicaapp.com");
        adminUser.setRole(Role.ROLE_ADMIN);
        adminUser.setActivo(true);

        regularUser = new Usuario();
        regularUser.setId("user_1");
        regularUser.setEmail("paciente@clinicaapp.com");
        regularUser.setRole(Role.ROLE_USER);
        regularUser.setActivo(true);
    }

    private void authenticateAs(Usuario user) {
        UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                user.getEmail(),
                "password",
                Collections.singletonList(new SimpleGrantedAuthority(user.getRole().name()))
        );
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @Test
    void testAccesoDenegadoParaUsuarioNormalEnSuspension() {
        authenticateAs(regularUser);
        when(usuarioRepo.findByEmail("paciente@clinicaapp.com")).thenReturn(regularUser);

        Map<String, Object> payload = Map.of("tipo", "TEMPORAL", "minutos", 30, "motivo", "Infracción");

        ResponseEntity<?> response = controller.suspenderUsuario("user_1", payload, null, request);

        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verify(supervisionService, never()).suspenderUsuario(any(), any(), any(), any(), any(), any());
    }

    @Test
    void testAccesoPermitidoParaSuperAdminEnSuspension() {
        authenticateAs(adminUser);
        when(usuarioRepo.findByEmail("superadmin@clinicaapp.com")).thenReturn(adminUser);
        when(supervisionService.suspenderUsuario(eq("user_1"), eq("superadmin@clinicaapp.com"), eq("TEMPORAL"), eq(30), eq("Infracción grave"), any()))
                .thenReturn(Map.of("success", true));

        Map<String, Object> payload = Map.of("tipo", "TEMPORAL", "minutos", 30, "motivo", "Infracción grave");

        ResponseEntity<?> response = controller.suspenderUsuario("user_1", payload, null, request);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(supervisionService, times(1)).suspenderUsuario(eq("user_1"), eq("superadmin@clinicaapp.com"), eq("TEMPORAL"), eq(30), eq("Infracción grave"), any());
    }

    @Test
    void testAccesoDenegadoParaUsuarioNormalEnCierreDeSesiones() {
        authenticateAs(regularUser);
        when(usuarioRepo.findByEmail("paciente@clinicaapp.com")).thenReturn(regularUser);

        ResponseEntity<?> response = controller.cerrarSesionesUsuario("user_1", null, null, request);

        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verify(supervisionService, never()).cerrarSesionesUsuario(any(), any(), any(), any());
    }

    @Test
    void testUsuarioPuedeResponderMensajeDirecto() {
        authenticateAs(regularUser);

        MensajeDirecto respuestaMock = new MensajeDirecto();
        respuestaMock.setId("msg_resp_1");
        respuestaMock.setContenido("Hola admin, gracias por la información.");
        respuestaMock.setOrigen("USUARIO");

        when(mensajeDirectoService.responderMensajeUsuario(eq("paciente@clinicaapp.com"), eq("Hola admin, gracias por la información."), any()))
                .thenReturn(respuestaMock);

        Map<String, String> payload = Map.of("contenido", "Hola admin, gracias por la información.");

        ResponseEntity<?> response = controller.responderSuperAdmin(payload);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(mensajeDirectoService, times(1)).responderMensajeUsuario(eq("paciente@clinicaapp.com"), eq("Hola admin, gracias por la información."), any());
    }

    @Test
    void testSesionSoporteSoloSuperAdmin() {
        // 1. Usuario normal intenta iniciar soporte -> FORBIDDEN
        authenticateAs(regularUser);
        when(usuarioRepo.findByEmail("paciente@clinicaapp.com")).thenReturn(regularUser);

        ResponseEntity<?> responseDenied = controller.iniciarSoporte("user_target", null, null, request);
        assertEquals(HttpStatus.FORBIDDEN, responseDenied.getStatusCode());
        verify(supervisionService, never()).iniciarSesionSoporte(any(), any(), any(), any(), any());

        // 2. Super Admin inicia soporte -> OK
        authenticateAs(adminUser);
        when(usuarioRepo.findByEmail("superadmin@clinicaapp.com")).thenReturn(adminUser);
        when(supervisionService.iniciarSesionSoporte(eq("user_target"), eq("superadmin@clinicaapp.com"), eq("Soporte técnico administrativo"), eq(15), any()))
                .thenReturn(Map.of("success", true, "duracionMinutos", 15));

        ResponseEntity<?> responseAllowed = controller.iniciarSoporte("user_target", null, null, request);
        assertEquals(HttpStatus.OK, responseAllowed.getStatusCode());
        verify(supervisionService, times(1)).iniciarSesionSoporte(eq("user_target"), eq("superadmin@clinicaapp.com"), eq("Soporte técnico administrativo"), eq(15), any());
    }
}
