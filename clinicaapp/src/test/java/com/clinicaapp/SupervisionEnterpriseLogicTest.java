package com.clinicaapp;

import com.clinicaapp.model.AuditoriaSupervision;
import com.clinicaapp.model.MensajeDirecto;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.repository.AuditoriaSupervisionRepository;
import com.clinicaapp.repository.MensajeDirectoRepository;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.UserSessionTracker;
import com.clinicaapp.service.impl.MensajeDirectoServiceImpl;
import com.clinicaapp.service.impl.UsuarioSupervisionServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.javamail.JavaMailSender;

import java.time.LocalDateTime;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class SupervisionEnterpriseLogicTest {

    @Mock
    private UsuarioRepository usuarioRepo;

    @Mock
    private AuditoriaSupervisionRepository auditoriaRepo;

    @Mock
    private MensajeDirectoRepository mensajeRepo;

    @Mock
    private UserSessionTracker sessionTracker;

    @Mock
    private JavaMailSender mailSender;

    @InjectMocks
    private UsuarioSupervisionServiceImpl supervisionService;

    @InjectMocks
    private MensajeDirectoServiceImpl mensajeService;

    private Usuario mockUser;

    @BeforeEach
    void setUp() {
        mockUser = new Usuario();
        mockUser.setId("user123");
        mockUser.setNombre("Carlos Pérez");
        mockUser.setEmail("carlos@clinicaapp.com");
        mockUser.setRole(Role.ROLE_USER);
        mockUser.setActivo(true);
        mockUser.setSuspendido(false);
    }

    @Test
    void testSuspenderUsuarioTemporal() {
        when(usuarioRepo.findById("user123")).thenReturn(Optional.of(mockUser));
        when(usuarioRepo.save(any(Usuario.class))).thenAnswer(i -> i.getArgument(0));

        Map<String, Object> result = supervisionService.suspenderUsuario(
                "user123", "admin@clinicaapp.com", "TEMPORAL", 60, "Conducta sospechosa", "192.168.1.100"
        );

        assertTrue((Boolean) result.get("success"));
        assertTrue(mockUser.isSuspendido());
        assertEquals("TEMPORAL", mockUser.getTipoSuspension());
        assertEquals("Conducta sospechosa", mockUser.getMotivoSuspension());
        assertNotNull(mockUser.getFechaFinSuspension());
        verify(auditoriaRepo, atLeast(1)).save(any(AuditoriaSupervision.class));
    }

    @Test
    void testReactivarUsuario() {
        mockUser.setSuspendido(true);
        mockUser.setTipoSuspension("PERMANENTE");
        mockUser.setMotivoSuspension("Sanción anterior");

        when(usuarioRepo.findById("user123")).thenReturn(Optional.of(mockUser));
        when(usuarioRepo.save(any(Usuario.class))).thenAnswer(i -> i.getArgument(0));

        Map<String, Object> result = supervisionService.reactivarUsuario(
                "user123", "admin@clinicaapp.com", "Revisión exitosa de caso", "192.168.1.100"
        );

        assertTrue((Boolean) result.get("success"));
        assertFalse(mockUser.isSuspendido());
        assertNull(mockUser.getMotivoSuspension());
        verify(auditoriaRepo, times(1)).save(any(AuditoriaSupervision.class));
    }

    @Test
    void testCerrarSesionesUsuario() {
        when(usuarioRepo.findById("user123")).thenReturn(Optional.of(mockUser));
        when(usuarioRepo.save(any(Usuario.class))).thenAnswer(i -> i.getArgument(0));

        Map<String, Object> result = supervisionService.cerrarSesionesUsuario(
                "user123", "admin@clinicaapp.com", "Cierre preventivo", "192.168.1.100"
        );

        assertTrue((Boolean) result.get("success"));
        assertNotNull(mockUser.getRevokedSessionsBefore());
        verify(sessionTracker, times(1)).invalidarSesionUsuario(mockUser.getEmail());
        verify(auditoriaRepo, times(1)).save(any(AuditoriaSupervision.class));
    }

    @Test
    void testChatBidireccionalAdminToUserAndReply() {
        when(usuarioRepo.findById("user123")).thenReturn(Optional.of(mockUser));
        when(usuarioRepo.findByEmail("carlos@clinicaapp.com")).thenReturn(mockUser);
        when(mensajeRepo.save(any(MensajeDirecto.class))).thenAnswer(i -> {
            MensajeDirecto m = i.getArgument(0);
            m.setId("msg_generated_1");
            return m;
        });

        // 1. Admin envía mensaje
        MensajeDirecto msgAdmin = mensajeService.enviarMensajeAdmin(
                "admin@clinicaapp.com", "Super Admin", "user123", "Alerta", "Por favor actualiza tu perfil"
        );

        assertNotNull(msgAdmin);
        assertEquals("SUPER_ADMIN", msgAdmin.getOrigen());
        assertEquals("user123", msgAdmin.getConversacionUsuarioId());
        assertEquals("ENVIADO", msgAdmin.getEstadoMensaje());

        // 2. Usuario responde al Super Admin
        MensajeDirecto msgReply = mensajeService.responderMensajeUsuario(
                "carlos@clinicaapp.com", "Entendido, ya lo he actualizado.", "Re: Alerta"
        );

        assertNotNull(msgReply);
        assertEquals("USUARIO", msgReply.getOrigen());
        assertEquals("user123", msgReply.getConversacionUsuarioId());
        assertEquals("ENVIADO", msgReply.getEstadoMensaje());
    }
}
