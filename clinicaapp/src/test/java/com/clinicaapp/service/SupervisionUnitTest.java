package com.clinicaapp.service;

import com.clinicaapp.model.MensajeDirecto;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.repository.MensajeDirectoRepository;
import com.clinicaapp.repository.UsuarioActividadRepository;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.impl.MensajeDirectoServiceImpl;
import com.clinicaapp.service.impl.UsuarioSupervisionServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
public class SupervisionUnitTest {

    @Mock
    private UsuarioRepository usuarioRepo;

    @Mock
    private UsuarioActividadRepository actividadRepo;

    @Mock
    private MensajeDirectoRepository mensajeDirectoRepo;

    @Mock
    private IEmailService emailService;

    @Mock
    private LogActividadService logActividadService;

    @Mock
    private UserSessionTracker sessionTracker;

    @InjectMocks
    private UsuarioSupervisionServiceImpl supervisionService;

    @InjectMocks
    private MensajeDirectoServiceImpl mensajeDirectoService;

    private Usuario superAdmin;
    private Usuario normalUser;
    private Usuario otherUser;

    @BeforeEach
    void setUp() {
        superAdmin = new Usuario();
        superAdmin.setId("admin-001");
        superAdmin.setEmail("admin@clinicaapp.com");
        superAdmin.setNombre("Super");
        superAdmin.setApellido("Administrador");
        superAdmin.setRole(Role.ROLE_ADMIN);
        superAdmin.setActivo(true);

        normalUser = new Usuario();
        normalUser.setId("user-001");
        normalUser.setEmail("samuel@clinicaapp.com");
        normalUser.setNombre("Samuel");
        normalUser.setApellido("Perez");
        normalUser.setRole(Role.ROLE_USER);
        normalUser.setActivo(true);

        otherUser = new Usuario();
        otherUser.setId("user-002");
        otherUser.setEmail("maria@clinicaapp.com");
        otherUser.setNombre("Maria");
        otherUser.setApellido("Gomez");
        otherUser.setRole(Role.ROLE_USER);
        otherUser.setActivo(true);
    }

    @Test
    @DisplayName("Test 1: Registrar telemetria y verificar presencia en memoria")
    void testRegistrarActividadYPresencia() {
        when(usuarioRepo.findById("user-001")).thenReturn(Optional.of(normalUser));
        when(usuarioRepo.findByEmail("samuel@clinicaapp.com")).thenReturn(normalUser);
        when(sessionTracker.getAllActiveSessions()).thenReturn(Collections.emptyList());
        when(actividadRepo.findTop20ByEmailOrderByFechaHoraDesc(anyString())).thenReturn(Collections.emptyList());

        // Registrar navegacion a Citas
        supervisionService.registrarActividad(
                "user-001", "samuel@clinicaapp.com", "Samuel Perez",
                "ENTRADA_SECCION", "Citas", "Entro a Citas",
                "/usuario/citas", "192.168.1.10", "Desktop", "Chrome", "Meta"
        );

        verify(actividadRepo, times(1)).save(any());

        // Consultar estado en vivo
        Map<String, Object> estado = supervisionService.obtenerEstadoUsuario("samuel@clinicaapp.com");
        assertTrue((Boolean) estado.get("encontrado"));
        assertTrue((Boolean) estado.get("online"));
        assertEquals("Citas", estado.get("seccionActual"));
        assertEquals("/usuario/citas", estado.get("urlActual"));
        assertEquals("Chrome", estado.get("navegador"));
    }

    @Test
    @DisplayName("Test 2: Transicion de secciones (Citas -> Historial -> Perfil)")
    void testTransicionSecciones() {
        when(usuarioRepo.findByEmail("samuel@clinicaapp.com")).thenReturn(normalUser);
        when(sessionTracker.getAllActiveSessions()).thenReturn(Collections.emptyList());
        when(actividadRepo.findTop20ByEmailOrderByFechaHoraDesc(anyString())).thenReturn(Collections.emptyList());

        // 1. Citas
        supervisionService.registrarActividad("user-001", "samuel@clinicaapp.com", "Samuel Perez", "ENTRADA_SECCION", "Citas", "Entro a Citas", "/citas", "127.0.0.1", "Desktop", "Chrome", null);
        Map<String, Object> e1 = supervisionService.obtenerEstadoUsuario("samuel@clinicaapp.com");
        assertEquals("Citas", e1.get("seccionActual"));

        // 2. Historial
        supervisionService.registrarActividad("user-001", "samuel@clinicaapp.com", "Samuel Perez", "ENTRADA_SECCION", "Historial", "Entro a Historial", "/historial", "127.0.0.1", "Desktop", "Chrome", null);
        Map<String, Object> e2 = supervisionService.obtenerEstadoUsuario("samuel@clinicaapp.com");
        assertEquals("Historial", e2.get("seccionActual"));

        // 3. Perfil
        supervisionService.registrarActividad("user-001", "samuel@clinicaapp.com", "Samuel Perez", "ENTRADA_SECCION", "Perfil", "Entro a Perfil", "/perfil", "127.0.0.1", "Desktop", "Chrome", null);
        Map<String, Object> e3 = supervisionService.obtenerEstadoUsuario("samuel@clinicaapp.com");
        assertEquals("Perfil", e3.get("seccionActual"));
    }

    @Test
    @DisplayName("Test 3: Envio de mensaje directo aislado a Samuel sin fuga a Maria")
    void testAislamientoMensajeriaDirecta() {
        when(usuarioRepo.findById("user-001")).thenReturn(Optional.of(normalUser));
        when(mensajeDirectoRepo.save(any(MensajeDirecto.class))).thenAnswer(i -> i.getArgument(0));

        // Super Admin envia mensaje a Samuel
        MensajeDirecto msg = mensajeDirectoService.enviarMensajeAdmin(
                superAdmin.getEmail(), superAdmin.getNombreCompleto(),
                "user-001", "Aviso Privado", "Hola Samuel, mensaje administrativo"
        );

        assertNotNull(msg);
        assertEquals("samuel@clinicaapp.com", msg.getDestinatarioEmail());
        assertEquals("user-001", msg.getDestinatarioId());
        assertEquals("Hola Samuel, mensaje administrativo", msg.getContenido());
        assertFalse(msg.isLeido());

        // Verificar que la consulta de mensajes de Maria este completamente aislada
        when(mensajeDirectoRepo.findByDestinatarioEmailOrderByFechaEnvioDesc("maria@clinicaapp.com"))
                .thenReturn(Collections.emptyList());

        List<MensajeDirecto> mensajesMaria = mensajeDirectoService.obtenerMensajesUsuario("maria@clinicaapp.com");
        assertTrue(mensajesMaria.isEmpty(), "Maria no debe recibir el mensaje enviado a Samuel");
    }

    @Test
    @DisplayName("Test 4: Marcar mensaje como leido y verificar pertenencia")
    void testMarcarComoLeido() {
        MensajeDirecto msg = new MensajeDirecto("admin@clinicaapp.com", "Admin", "user-001", "samuel@clinicaapp.com", "Samuel", "Test", "Cuerpo", "ADMIN_ALERT");
        msg.setId("msg-100");
        msg.setLeido(false);

        when(mensajeDirectoRepo.findById("msg-100")).thenReturn(Optional.of(msg));

        // Intento de otro usuario marcando como leido (IDOR Protection)
        boolean hackAttempt = mensajeDirectoService.marcarComoLeido("msg-100", "hacker@clinicaapp.com");
        assertFalse(hackAttempt, "Un usuario ajeno no puede marcar como leido el mensaje de otro");
        assertFalse(msg.isLeido());

        // Dueno legitimo marcando como leido
        boolean ok = mensajeDirectoService.marcarComoLeido("msg-100", "samuel@clinicaapp.com");
        assertTrue(ok, "El destinatario legitimo puede marcarlo como leido");
        assertTrue(msg.isLeido());
        assertNotNull(msg.getFechaLectura());
        verify(mensajeDirectoRepo, times(1)).save(msg);
    }
}
