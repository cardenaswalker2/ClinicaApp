package com.clinicaapp.controller.rest;

import com.clinicaapp.model.MensajeDirecto;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.model.UsuarioActividad;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IMensajeDirectoService;
import com.clinicaapp.service.IUsuarioSupervisionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/supervision")
@CrossOrigin(origins = "*")
public class ApiSupervisionController {

    @Autowired
    private IUsuarioSupervisionService supervisionService;

    @Autowired
    private IMensajeDirectoService mensajeDirectoService;

    @Autowired
    private UsuarioRepository usuarioRepo;

    // Helper de validación de Super Administrador tanto por sesión como por parámetro email
    private boolean isSuperAdmin(String explicitEmail) {
        // 1. Validar por SecurityContext (web session / OAuth2 / FormLogin)
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            // Verificar autoridades en el Authentication
            boolean hasAdminRole = auth.getAuthorities().stream()
                    .anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()) || "ADMIN".equals(a.getAuthority()));
            if (hasAdminRole) return true;

            // Verificar en base de datos si el usuario logueado es ROLE_ADMIN
            String currentUsername = auth.getName();
            if (currentUsername != null && !currentUsername.isBlank()) {
                Usuario u = usuarioRepo.findByEmail(currentUsername.trim());
                if (u != null && u.getRole() == Role.ROLE_ADMIN && u.isActivo()) {
                    return true;
                }
            }
        }

        // 2. Validar por email enviado (API móvil / llamadas autenticadas)
        if (explicitEmail != null && !explicitEmail.isBlank()) {
            Usuario u = usuarioRepo.findByEmail(explicitEmail.trim());
            return u != null && u.getRole() == Role.ROLE_ADMIN && u.isActivo();
        }

        return false;
    }

    // ── 1. LISTA DE USUARIOS PARA SUPERVISIÓN (SUPER ADMIN ONLY) ──
    @GetMapping("/usuarios")
    public ResponseEntity<?> getUsuariosSupervision(
            @RequestParam(required = false) String email,
            @RequestParam(defaultValue = "") String q) {

        if (!isSuperAdmin(email)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        List<Map<String, Object>> lista = supervisionService.obtenerListaUsuariosSupervision(q);
        return ResponseEntity.ok(lista);
    }

    // ── 2. ESTADO EN TIEMPO REAL DE UN USUARIO INDIVIDUAL (SUPER ADMIN ONLY) ──
    @GetMapping("/usuario/{idOrEmail}/estado")
    public ResponseEntity<?> getEstadoUsuario(
            @PathVariable String idOrEmail,
            @RequestParam(required = false) String email) {

        if (!isSuperAdmin(email)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        Map<String, Object> estado = supervisionService.obtenerEstadoUsuario(idOrEmail);
        return ResponseEntity.ok(estado);
    }

    // ── 3. HISTORIAL DE ACTIVIDAD RECIENTE (SUPER ADMIN ONLY) ──
    @GetMapping("/usuario/{idOrEmail}/historial")
    public ResponseEntity<?> getHistorialUsuario(
            @PathVariable String idOrEmail,
            @RequestParam(required = false) String email,
            @RequestParam(defaultValue = "20") int limite) {

        if (!isSuperAdmin(email)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        List<UsuarioActividad> historial = supervisionService.obtenerHistorialUsuario(idOrEmail, limite);
        return ResponseEntity.ok(historial);
    }

    // ── 4. ENVIAR MENSAJE DIRECTO INTERNO (SUPER ADMIN ONLY) ──
    @PostMapping("/mensajeria/enviar")
    public ResponseEntity<?> enviarMensajeDirecto(
            @RequestBody Map<String, String> payload,
            @RequestParam(required = false) String email) {

        String adminEmail = payload.get("adminEmail") != null ? payload.get("adminEmail") : email;
        if (!isSuperAdmin(adminEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        try {
            String destinatarioId = payload.get("destinatarioId");
            String asunto = payload.get("asunto");
            String contenido = payload.get("contenido");
            String remitenteNombre = payload.get("remitenteNombre");

            if (destinatarioId == null || destinatarioId.isBlank() || contenido == null || contenido.isBlank()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "El destinatario y el mensaje son obligatorios."));
            }

            MensajeDirecto guardado = mensajeDirectoService.enviarMensajeAdmin(
                    adminEmail,
                    remitenteNombre != null ? remitenteNombre : "Super Administrador",
                    destinatarioId,
                    asunto != null ? asunto : "Mensaje de la Administración",
                    contenido
            );

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Mensaje enviado exitosamente al usuario.",
                    "mensaje", guardado
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ── 5. HISTORIAL DE MENSAJES CON UN USUARIO ESPECÍFICO (SUPER ADMIN ONLY) ──
    @GetMapping("/mensajeria/conversacion/{idOrEmail}")
    public ResponseEntity<?> getConversacion(
            @PathVariable String idOrEmail,
            @RequestParam(required = false) String email) {

        if (!isSuperAdmin(email)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        List<MensajeDirecto> mensajes = mensajeDirectoService.obtenerConversacionConUsuario(idOrEmail);
        return ResponseEntity.ok(mensajes);
    }

    // ── 6. ENVIAR CORREO ELECTRÓNICO REAL (SUPER ADMIN ONLY) ──
    @PostMapping("/email/enviar")
    public ResponseEntity<?> enviarCorreoReal(
            @RequestBody Map<String, String> payload,
            @RequestParam(required = false) String email) {

        String adminEmail = payload.get("adminEmail") != null ? payload.get("adminEmail") : email;
        if (!isSuperAdmin(adminEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        try {
            String destinatarioEmail = payload.get("destinatarioEmail");
            String asunto = payload.get("asunto");
            String contenido = payload.get("contenido");

            if (destinatarioEmail == null || destinatarioEmail.isBlank() || asunto == null || asunto.isBlank() || contenido == null || contenido.isBlank()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Destinatario, asunto y contenido son campos requeridos."));
            }

            Map<String, Object> resultado = mensajeDirectoService.enviarEmailDirecto(
                    destinatarioEmail, asunto, contenido
            );

            if (Boolean.TRUE.equals(resultado.get("success"))) {
                return ResponseEntity.ok(resultado);
            } else {
                return ResponseEntity.badRequest().body(resultado);
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error en el servidor de correo: " + e.getMessage()));
        }
    }

    // ── 7. HEARTBEAT / TELEMETRÍA DE NAVEGACIÓN DEL USUARIO (ENDPOINT ACCESIBLE POR USUARIO AUTENTICADO) ──
    @PostMapping("/telemetria/heartbeat")
    public ResponseEntity<?> registrarHeartbeat(
            @RequestBody Map<String, String> payload,
            jakarta.servlet.http.HttpServletRequest request) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String userEmail = null;

        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            userEmail = auth.getName();
        } else if (payload.containsKey("email")) {
            userEmail = payload.get("email");
        }

        if (userEmail == null || userEmail.isBlank()) {
            return ResponseEntity.ok(Map.of("status", "ANONYMOUS"));
        }

        String seccion = payload.get("seccion");
        String url = payload.get("url");
        String accion = payload.get("accion");
        String tipoEvento = payload.get("tipoEvento");
        String metadata = payload.get("metadata");

        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) ip = request.getRemoteAddr();
        String ua = request.getHeader("User-Agent");

        String dispositivo = "Desktop";
        String navegador = "Browser";
        if (ua != null) {
            String ual = ua.toLowerCase();
            if (ual.contains("mobile") || ual.contains("android") || ual.contains("iphone")) dispositivo = "Mobile";
            else if (ual.contains("tablet") || ual.contains("ipad")) dispositivo = "Tablet";

            if (ual.contains("edg")) navegador = "Edge";
            else if (ual.contains("chrome")) navegador = "Chrome";
            else if (ual.contains("firefox")) navegador = "Firefox";
            else if (ual.contains("safari")) navegador = "Safari";
        }

        if (tipoEvento != null && !tipoEvento.isBlank()) {
            // Es un evento significativo (ej: entrada a sección, click importante, navegación)
            supervisionService.registrarActividad(
                    null, userEmail, null, tipoEvento, seccion, accion != null ? accion : "Navegó en " + seccion,
                    url, ip, dispositivo, navegador, metadata
            );
        } else {
            // Es solo un pulso heartbeat periódico
            supervisionService.actualizarHeartbeat(userEmail, seccion, url);
        }

        return ResponseEntity.ok(Map.of("status", "RECORDED"));
    }

    // ── 8. BANDEJA DE ENTRADA DEL USUARIO LOGUEADO (NOTIFICACIONES/MENSAJES) ──
    @GetMapping("/mis-mensajes")
    public ResponseEntity<?> getMisMensajes() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("No autenticado");
        }

        String email = auth.getName();
        List<MensajeDirecto> mensajes = mensajeDirectoService.obtenerMensajesUsuario(email);
        long noLeidos = mensajeDirectoService.contarNoLeidos(email);

        return ResponseEntity.ok(Map.of(
                "mensajes", mensajes,
                "noLeidos", noLeidos
        ));
    }

    // ── 9. MARCAR MENSAJE COMO LEÍDO ──
    @PostMapping("/mis-mensajes/{id}/leer")
    public ResponseEntity<?> marcarLeido(@PathVariable String id) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = (auth != null && auth.isAuthenticated()) ? auth.getName() : null;

        boolean ok = mensajeDirectoService.marcarComoLeido(id, email);
        return ResponseEntity.ok(Map.of("success", ok));
    }
}
