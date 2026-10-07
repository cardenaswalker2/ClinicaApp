package com.clinicaapp.controller.rest;

import com.clinicaapp.model.MensajeDirecto;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IMensajeDirectoService;
import com.clinicaapp.service.IUsuarioSupervisionService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
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

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private ApiSupervisionController controller;

    private Usuario superAdminUser;
    private Usuario regularAdminUser;
    private Usuario normalUser;

    @BeforeEach
    void setUp() {
        superAdminUser = new Usuario();
        superAdminUser.setEmail("superadmin@clinicaapp.com");
        superAdminUser.setRole(Role.ROLE_ADMIN);
        superAdminUser.setActivo(true);

        regularAdminUser = new Usuario();
        regularAdminUser.setEmail("admin_clinica@clinicaapp.com");
        regularAdminUser.setRole(Role.ROLE_CLINICA);
        regularAdminUser.setActivo(true);

        normalUser = new Usuario();
        normalUser.setEmail("samuel@clinicaapp.com");
        normalUser.setRole(Role.ROLE_USER);
        normalUser.setActivo(true);

        SecurityContextHolder.setContext(securityContext);
    }

    private void mockAuth(String email, String role) {
        if (email == null) {
            when(securityContext.getAuthentication()).thenReturn(null);
            return;
        }
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.isAuthenticated()).thenReturn(true);
        when(authentication.getName()).thenReturn(email);
        when(authentication.getPrincipal()).thenReturn(email);

        Collection<GrantedAuthority> authorities = Collections.singletonList(new SimpleGrantedAuthority(role));
        doReturn(authorities).when(authentication).getAuthorities();
    }

    @Test
    @DisplayName("Endpoint /api/supervision/usuarios - Denegado a ROLE_USER y ROLE_CLINICA")
    void testGetUsuariosForbiddenForNonSuperAdmin() {
        // Intento con ROLE_USER
        mockAuth("samuel@clinicaapp.com", "ROLE_USER");
        when(usuarioRepo.findByEmail("samuel@clinicaapp.com")).thenReturn(normalUser);

        ResponseEntity<?> respUser = controller.getUsuariosSupervision(null, "");
        assertEquals(HttpStatus.FORBIDDEN, respUser.getStatusCode());

        // Intento con ROLE_CLINICA (Admin normal de clínica)
        mockAuth("admin_clinica@clinicaapp.com", "ROLE_CLINICA");
        when(usuarioRepo.findByEmail("admin_clinica@clinicaapp.com")).thenReturn(regularAdminUser);

        ResponseEntity<?> respClinica = controller.getUsuariosSupervision(null, "");
        assertEquals(HttpStatus.FORBIDDEN, respClinica.getStatusCode());
    }

    @Test
    @DisplayName("Endpoint /api/supervision/usuarios - Permitido exclusivamente a ROLE_ADMIN")
    void testGetUsuariosAllowedForSuperAdmin() {
        mockAuth("superadmin@clinicaapp.com", "ROLE_ADMIN");
        when(supervisionService.obtenerListaUsuariosSupervision(anyString()))
                .thenReturn(List.of(Map.of("id", "user-1", "nombre", "Samuel")));

        ResponseEntity<?> response = controller.getUsuariosSupervision(null, "");
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
    }

    @Test
    @DisplayName("Endpoint /api/supervision/usuario/{id}/estado - Denegado a usuarios normales")
    void testGetEstadoUsuarioForbidden() {
        mockAuth("samuel@clinicaapp.com", "ROLE_USER");
        ResponseEntity<?> response = controller.getEstadoUsuario("other-user", null);
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
    }

    @Test
    @DisplayName("Endpoint /api/supervision/mensajeria/enviar - Denegado a usuarios normales")
    void testEnviarMensajeForbidden() {
        mockAuth("samuel@clinicaapp.com", "ROLE_USER");
        Map<String, String> payload = Map.of(
                "destinatarioId", "user-2",
                "contenido", "Mensaje no autorizado"
        );
        ResponseEntity<?> response = controller.enviarMensajeDirecto(payload, null);
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
    }
}
