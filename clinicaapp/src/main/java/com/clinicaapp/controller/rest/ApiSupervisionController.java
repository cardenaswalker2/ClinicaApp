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

    // Helper para extraer de forma segura el email del usuario desde cualquier tipo de Authentication (OAuth2, Oidc, UserDetails, Form)
    private String extractEmailFromAuth(Authentication auth) {
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return null;
        }
        Object principal = auth.getPrincipal();
        if (principal instanceof org.springframework.security.oauth2.core.oidc.user.OidcUser oidcUser) {
            String email = (String) oidcUser.getClaims().get("email");
            if (email != null && !email.isBlank()) return email;
        }
        if (principal instanceof org.springframework.security.oauth2.core.user.OAuth2User oAuth2User) {
            String email = (String) oAuth2User.getAttributes().get("email");
            if (email != null && !email.isBlank()) return email;
        }
        if (principal instanceof org.springframework.security.core.userdetails.UserDetails userDetails) {
            return userDetails.getUsername();
        }
        return auth.getName();
    }

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
            String currentUsername = extractEmailFromAuth(auth);
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
    @PostMapping(value = "/email/enviar", consumes = {"multipart/form-data", "application/json"})
    public ResponseEntity<?> enviarCorreoReal(
            @RequestParam(value = "destinatarioEmail", required = false) String destinatarioEmail,
            @RequestParam(value = "asunto", required = false) String asunto,
            @RequestParam(value = "contenido", required = false) String contenido,
            @RequestParam(value = "adminEmail", required = false) String adminEmail,
            @RequestParam(value = "archivo", required = false) org.springframework.web.multipart.MultipartFile archivo,
            @RequestBody(required = false) Map<String, String> payload,
            @RequestParam(required = false) String email) {

        if (payload != null) {
            if (destinatarioEmail == null) destinatarioEmail = payload.get("destinatarioEmail");
            if (asunto == null) asunto = payload.get("asunto");
            if (contenido == null) contenido = payload.get("contenido");
            if (adminEmail == null) adminEmail = payload.get("adminEmail");
        }

        String senderEmail = adminEmail != null ? adminEmail : email;
        if (!isSuperAdmin(senderEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        try {
            if (destinatarioEmail == null || destinatarioEmail.isBlank() || asunto == null || asunto.isBlank() || contenido == null || contenido.isBlank()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Destinatario, asunto y contenido son campos requeridos."));
            }

            String nombreArchivo = null;
            byte[] archivoBytes = null;

            if (archivo != null && !archivo.isEmpty()) {
                // Validar tamaño máximo (10MB)
                if (archivo.getSize() > 10 * 1024 * 1024) {
                    return ResponseEntity.badRequest().body(Map.of("error", "El archivo no debe superar los 10MB."));
                }

                String origName = archivo.getOriginalFilename();
                if (origName != null) {
                    String lower = origName.toLowerCase();
                    // Bloquear ejecutables peligrosos
                    if (lower.endsWith(".exe") || lower.endsWith(".bat") || lower.endsWith(".cmd") || lower.endsWith(".sh") || lower.endsWith(".vbs") || lower.endsWith(".js") || lower.endsWith(".jar")) {
                        return ResponseEntity.badRequest().body(Map.of("error", "Tipo de archivo no permitido por seguridad."));
                    }
                    nombreArchivo = origName;
                    archivoBytes = archivo.getBytes();
                }
            }

            Map<String, Object> resultado = mensajeDirectoService.enviarEmailDirectoConAdjunto(
                    destinatarioEmail, asunto, contenido, nombreArchivo, archivoBytes
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
        String userEmail = extractEmailFromAuth(auth);

        if ((userEmail == null || userEmail.isBlank()) && payload.containsKey("email")) {
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
        String email = extractEmailFromAuth(auth);
        if (email == null || email.isBlank()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("No autenticado");
        }

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
        String email = extractEmailFromAuth(auth);

        boolean ok = mensajeDirectoService.marcarComoLeido(id, email);
        return ResponseEntity.ok(Map.of("success", ok));
    }

    // ── 10. USUARIO RESPONDE AL SUPER ADMIN (CHAT BIDIRECCIONAL REAL) ──
    @PostMapping("/mis-mensajes/responder")
    public ResponseEntity<?> responderSuperAdmin(@RequestBody Map<String, String> payload) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String userEmail = extractEmailFromAuth(auth);
        if (userEmail == null || userEmail.isBlank()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "No autenticado"));
        }

        String contenido = payload.get("contenido");
        if (contenido == null || contenido.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "El mensaje no puede estar vacío"));
        }

        try {
            String asunto = payload.get("asunto") != null ? payload.get("asunto") : "Respuesta a la Administración";
            MensajeDirecto respuesta = mensajeDirectoService.responderMensajeUsuario(userEmail, contenido.trim(), asunto);
            return ResponseEntity.ok(Map.of("success", true, "mensaje", respuesta));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ── 11. CERRAR FORZOSAMENTE SESIONES DE UN USUARIO (SUPER ADMIN ONLY) ──
    @PostMapping("/usuario/{idOrEmail}/cerrar-sesiones")
    public ResponseEntity<?> cerrarSesionesUsuario(
            @PathVariable String idOrEmail,
            @RequestBody(required = false) Map<String, String> payload,
            @RequestParam(required = false) String email,
            jakarta.servlet.http.HttpServletRequest request) {

        String adminEmail = payload != null && payload.get("adminEmail") != null ? payload.get("adminEmail") : email;
        if (adminEmail == null) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            adminEmail = extractEmailFromAuth(auth);
        }

        if (!isSuperAdmin(adminEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        String motivo = payload != null ? payload.get("motivo") : "Cierre administrativo de sesiones";
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isBlank() || "unknown".equalsIgnoreCase(ip)) ip = request.getRemoteAddr();

        Map<String, Object> res = supervisionService.cerrarSesionesUsuario(idOrEmail, adminEmail, motivo, ip);
        return ResponseEntity.ok(res);
    }

    // ── 12. SUSPENDER USUARIO (TEMPORAL O PERMANENTE) (SUPER ADMIN ONLY) ──
    @PostMapping("/usuario/{idOrEmail}/suspender")
    public ResponseEntity<?> suspenderUsuario(
            @PathVariable String idOrEmail,
            @RequestBody Map<String, Object> payload,
            @RequestParam(required = false) String email,
            jakarta.servlet.http.HttpServletRequest request) {

        String adminEmail = payload.get("adminEmail") != null ? payload.get("adminEmail").toString() : email;
        if (adminEmail == null) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            adminEmail = extractEmailFromAuth(auth);
        }

        if (!isSuperAdmin(adminEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        String tipo = payload.get("tipo") != null ? payload.get("tipo").toString() : "TEMPORAL";
        String motivo = payload.get("motivo") != null ? payload.get("motivo").toString() : "";
        Integer minutos = payload.get("minutos") != null ? Integer.valueOf(payload.get("minutos").toString()) : null;

        if (motivo.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "El motivo de la suspensión es obligatorio."));
        }

        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isBlank() || "unknown".equalsIgnoreCase(ip)) ip = request.getRemoteAddr();

        Map<String, Object> res = supervisionService.suspenderUsuario(idOrEmail, adminEmail, tipo, minutos, motivo, ip);
        return ResponseEntity.ok(res);
    }

    // ── 13. REACTIVAR USUARIO MANUALMENTE (SUPER ADMIN ONLY) ──
    @PostMapping("/usuario/{idOrEmail}/reactivar")
    public ResponseEntity<?> reactivarUsuario(
            @PathVariable String idOrEmail,
            @RequestBody(required = false) Map<String, String> payload,
            @RequestParam(required = false) String email,
            jakarta.servlet.http.HttpServletRequest request) {

        String adminEmail = payload != null && payload.get("adminEmail") != null ? payload.get("adminEmail") : email;
        if (adminEmail == null) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            adminEmail = extractEmailFromAuth(auth);
        }

        if (!isSuperAdmin(adminEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        String motivo = payload != null ? payload.get("motivo") : "Reactivación administrativa";
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isBlank() || "unknown".equalsIgnoreCase(ip)) ip = request.getRemoteAddr();

        Map<String, Object> res = supervisionService.reactivarUsuario(idOrEmail, adminEmail, motivo, ip);
        return ResponseEntity.ok(res);
    }

    // ── 14. DISPARAR RECUPERACIÓN DE CONTRASEÑA SEGURA POR EMAIL (SUPER ADMIN ONLY) ──
    @PostMapping("/usuario/{idOrEmail}/reset-password")
    public ResponseEntity<?> resetPasswordSeguro(
            @PathVariable String idOrEmail,
            @RequestBody(required = false) Map<String, String> payload,
            @RequestParam(required = false) String email,
            jakarta.servlet.http.HttpServletRequest request) {

        String adminEmail = payload != null && payload.get("adminEmail") != null ? payload.get("adminEmail") : email;
        if (adminEmail == null) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            adminEmail = extractEmailFromAuth(auth);
        }

        if (!isSuperAdmin(adminEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isBlank() || "unknown".equalsIgnoreCase(ip)) ip = request.getRemoteAddr();

        Map<String, Object> res = supervisionService.dispararResetPasswordSeguro(idOrEmail, adminEmail, ip);
        return ResponseEntity.ok(res);
    }

    // ── 15. INICIAR SESIÓN DELEGADA DE SOPORTE ADMINISTRATIVO (SUPER ADMIN ONLY) ──
    @PostMapping("/usuario/{idOrEmail}/soporte/iniciar")
    public ResponseEntity<?> iniciarSoporte(
            @PathVariable String idOrEmail,
            @RequestBody(required = false) Map<String, String> payload,
            @RequestParam(required = false) String email,
            jakarta.servlet.http.HttpServletRequest request) {

        String adminEmail = payload != null && payload.get("adminEmail") != null ? payload.get("adminEmail") : email;
        if (adminEmail == null) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            adminEmail = extractEmailFromAuth(auth);
        }

        if (!isSuperAdmin(adminEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        String motivo = payload != null && payload.get("motivo") != null ? payload.get("motivo") : "Soporte técnico administrativo";
        Integer minutos = payload != null && payload.get("minutos") != null ? Integer.valueOf(payload.get("minutos")) : 15;
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isBlank() || "unknown".equalsIgnoreCase(ip)) ip = request.getRemoteAddr();

        Map<String, Object> res = supervisionService.iniciarSesionSoporte(idOrEmail, adminEmail, motivo, minutos, ip);
        return ResponseEntity.ok(res);
    }

    // ── 16. FINALIZAR SESIÓN DELEGADA DE SOPORTE (SUPER ADMIN ONLY) ──
    @PostMapping("/usuario/{idOrEmail}/soporte/finalizar")
    public ResponseEntity<?> finalizarSoporte(
            @PathVariable String idOrEmail,
            @RequestBody(required = false) Map<String, String> payload,
            @RequestParam(required = false) String email,
            jakarta.servlet.http.HttpServletRequest request) {

        String adminEmail = payload != null && payload.get("adminEmail") != null ? payload.get("adminEmail") : email;
        if (adminEmail == null) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            adminEmail = extractEmailFromAuth(auth);
        }

        if (!isSuperAdmin(adminEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isBlank() || "unknown".equalsIgnoreCase(ip)) ip = request.getRemoteAddr();

        Map<String, Object> res = supervisionService.finalizarSesionSoporte(idOrEmail, adminEmail, ip);
        return ResponseEntity.ok(res);
    }

    // ── 17. OBTENER AUDITORÍAS DE UN USUARIO (SUPER ADMIN ONLY) ──
    @GetMapping("/usuario/{idOrEmail}/auditorias")
    public ResponseEntity<?> getAuditoriasUsuario(
            @PathVariable String idOrEmail,
            @RequestParam(required = false) String email) {

        if (!isSuperAdmin(email)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Acceso denegado. Exclusivo para Super Administrador."));
        }

        return ResponseEntity.ok(supervisionService.obtenerAuditoriasUsuario(idOrEmail));
    }
}
