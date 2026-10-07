package com.clinicaapp.service.impl;

import com.clinicaapp.model.AuditoriaSupervision;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.model.UsuarioActividad;
import com.clinicaapp.model.UserSessionDetails;
import com.clinicaapp.repository.AuditoriaSupervisionRepository;
import com.clinicaapp.repository.UsuarioActividadRepository;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IUsuarioSupervisionService;
import com.clinicaapp.service.UserSessionTracker;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class UsuarioSupervisionServiceImpl implements IUsuarioSupervisionService {

    @Autowired
    private UsuarioActividadRepository actividadRepo;

    @Autowired
    private UsuarioRepository usuarioRepo;

    @Autowired
    private AuditoriaSupervisionRepository auditoriaSupervisionRepo;

    @Autowired
    private UserSessionTracker sessionTracker;

    // Cache en memoria para presencia y estado en tiempo real (evita sobrecargar la BD en polling)
    private static final Map<String, PresenciaUsuario> presenciaMap = new ConcurrentHashMap<>();

    public static class PresenciaUsuario {
        private String email;
        private String seccionActual = "Inicio";
        private String urlActual = "/";
        private LocalDateTime ultimaActividad = LocalDateTime.now();
        private String ip = "127.0.0.1";
        private String dispositivo = "Desktop";
        private String navegador = "Chrome";
        private String os = "Windows";

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getSeccionActual() { return seccionActual; }
        public void setSeccionActual(String seccionActual) { this.seccionActual = seccionActual; }
        public String getUrlActual() { return urlActual; }
        public void setUrlActual(String urlActual) { this.urlActual = urlActual; }
        public LocalDateTime getUltimaActividad() { return ultimaActividad; }
        public void setUltimaActividad(LocalDateTime ultimaActividad) { this.ultimaActividad = ultimaActividad; }
        public String getIp() { return ip; }
        public void setIp(String ip) { this.ip = ip; }
        public String getDispositivo() { return dispositivo; }
        public void setDispositivo(String dispositivo) { this.dispositivo = dispositivo; }
        public String getNavegador() { return navegador; }
        public void setNavegador(String navegador) { this.navegador = navegador; }
        public String getOs() { return os; }
        public void setOs(String os) { this.os = os; }
    }

    @Override
    public void registrarActividad(String usuarioId, String email, String nombre, String tipoEvento, 
                                  String seccion, String accion, String url, String ip, 
                                  String dispositivo, String navegador, String metadata) {
        if (email == null && usuarioId != null) {
            Usuario u = usuarioRepo.findById(usuarioId).orElse(null);
            if (u != null) {
                email = u.getEmail();
                if (nombre == null) nombre = u.getNombreCompleto();
            }
        }

        if (email == null) return;

        // Actualizar Presencia en Memoria
        PresenciaUsuario presencia = presenciaMap.computeIfAbsent(email.toLowerCase(), k -> new PresenciaUsuario());
        presencia.setEmail(email);
        if (seccion != null && !seccion.isBlank()) presencia.setSeccionActual(seccion);
        if (url != null && !url.isBlank()) presencia.setUrlActual(url);
        presencia.setUltimaActividad(LocalDateTime.now());
        if (ip != null) presencia.setIp(ip);
        if (dispositivo != null) presencia.setDispositivo(dispositivo);
        if (navegador != null) presencia.setNavegador(navegador);

        // Guardar registro persistente en MongoDB
        UsuarioActividad actividad = new UsuarioActividad(
                usuarioId, email, nombre, tipoEvento, seccion, accion, url, ip, dispositivo, navegador, metadata
        );
        actividadRepo.save(actividad);
    }

    @Override
    public void actualizarHeartbeat(String email, String seccionActual, String urlActual) {
        if (email == null || email.isBlank()) return;
        String emailKey = email.toLowerCase();
        PresenciaUsuario presencia = presenciaMap.computeIfAbsent(emailKey, k -> new PresenciaUsuario());
        presencia.setEmail(email);
        if (seccionActual != null && !seccionActual.isBlank()) presencia.setSeccionActual(seccionActual);
        if (urlActual != null && !urlActual.isBlank()) presencia.setUrlActual(urlActual);
        presencia.setUltimaActividad(LocalDateTime.now());
    }

    @Override
    public Map<String, Object> obtenerEstadoUsuario(String usuarioIdOrEmail) {
        Map<String, Object> resultado = new HashMap<>();

        Usuario usuario = null;
        if (usuarioIdOrEmail.contains("@")) {
            usuario = usuarioRepo.findByEmail(usuarioIdOrEmail);
        } else {
            usuario = usuarioRepo.findById(usuarioIdOrEmail).orElse(null);
            if (usuario == null) {
                usuario = usuarioRepo.findByEmail(usuarioIdOrEmail);
            }
        }

        if (usuario == null) {
            resultado.put("encontrado", false);
            return resultado;
        }

        resultado.put("encontrado", true);
        resultado.put("id", usuario.getId());
        resultado.put("nombre", usuario.getNombreCompleto());
        resultado.put("email", usuario.getEmail());
        resultado.put("telefono", usuario.getTelefono() != null ? usuario.getTelefono() : "No registrado");
        resultado.put("rol", usuario.getRole() != null ? usuario.getRole().name() : "ROLE_USER");
        resultado.put("activo", usuario.isActivo());
        resultado.put("suspendido", usuario.isSuspendido());
        resultado.put("tipoSuspension", usuario.getTipoSuspension());
        resultado.put("motivoSuspension", usuario.getMotivoSuspension());
        resultado.put("fechaFinSuspension", usuario.getFechaFinSuspension());
        resultado.put("fotoUrl", usuario.getFotoUrl() != null ? usuario.getFotoUrl() : usuario.getFotoPerfilUrl());

        String emailKey = usuario.getEmail().toLowerCase();
        PresenciaUsuario presencia = presenciaMap.get(emailKey);

        boolean online = false;
        String seccion = "Desconocida";
        String url = "/";
        LocalDateTime ultimaActividad = null;
        String ip = "127.0.0.1";
        String dispositivo = "Desktop";
        String os = "Desconocido";
        String navegador = "Desconocido";

        // Revisar tracker de sesiones activas de Spring Security
        for (UserSessionDetails sess : sessionTracker.getAllActiveSessions()) {
            if (sess.getUsername() != null && sess.getUsername().equalsIgnoreCase(usuario.getEmail())) {
                online = true;
                if (sess.getIpAddress() != null) ip = sess.getIpAddress();
                if (sess.getDeviceType() != null) dispositivo = sess.getDeviceType();
                if (sess.getOperatingSystem() != null) os = sess.getOperatingSystem();
                if (sess.getBrowser() != null) navegador = sess.getBrowser();
                if (sess.getLastActivityTime() != null) ultimaActividad = sess.getLastActivityTime();
                break;
            }
        }

        if (presencia != null) {
            seccion = presencia.getSeccionActual();
            url = presencia.getUrlActual();
            if (presencia.getUltimaActividad() != null) {
                long segundos = Duration.between(presencia.getUltimaActividad(), LocalDateTime.now()).getSeconds();
                // Si la última actividad fue hace menos de 90 segundos, está definitivamente online
                if (segundos < 90) {
                    online = true;
                }
                if (ultimaActividad == null || presencia.getUltimaActividad().isAfter(ultimaActividad)) {
                    ultimaActividad = presencia.getUltimaActividad();
                }
            }
            if (presencia.getIp() != null && !presencia.getIp().isBlank()) ip = presencia.getIp();
            if (presencia.getDispositivo() != null && !presencia.getDispositivo().isBlank()) dispositivo = presencia.getDispositivo();
            if (presencia.getNavegador() != null && !presencia.getNavegador().isBlank()) navegador = presencia.getNavegador();
        }

        // Si no hay última actividad, buscar en los logs de MongoDB
        if (ultimaActividad == null) {
            List<UsuarioActividad> ultimos = actividadRepo.findTop20ByEmailOrderByFechaHoraDesc(usuario.getEmail());
            if (!ultimos.isEmpty()) {
                UsuarioActividad act = ultimos.get(0);
                ultimaActividad = act.getFechaHora();
                seccion = act.getSeccion();
                url = act.getUrl();
                if (act.getIp() != null) ip = act.getIp();
                if (act.getDispositivo() != null) dispositivo = act.getDispositivo();
                if (act.getNavegador() != null) navegador = act.getNavegador();
            }
        }

        resultado.put("online", online);
        resultado.put("seccionActual", seccion);
        resultado.put("urlActual", url);
        resultado.put("ip", ip);
        resultado.put("dispositivo", dispositivo);
        resultado.put("os", os);
        resultado.put("navegador", navegador);
        resultado.put("ultimaActividad", ultimaActividad);
        resultado.put("tiempoRelativo", calcularTiempoRelativo(ultimaActividad));

        // Actividades recientes (últimas 15)
        List<UsuarioActividad> eventos = actividadRepo.findTop20ByEmailOrderByFechaHoraDesc(usuario.getEmail());
        resultado.put("eventosRecientes", eventos);

        return resultado;
    }

    @Override
    public List<UsuarioActividad> obtenerHistorialUsuario(String usuarioIdOrEmail, int limite) {
        if (usuarioIdOrEmail.contains("@")) {
            return actividadRepo.findTop20ByEmailOrderByFechaHoraDesc(usuarioIdOrEmail);
        } else {
            return actividadRepo.findTop20ByUsuarioIdOrderByFechaHoraDesc(usuarioIdOrEmail);
        }
    }

    @Override
    public Page<UsuarioActividad> obtenerHistorialPaginado(String usuarioIdOrEmail, int pagina, int tamano) {
        Pageable pageable = PageRequest.of(pagina, tamano, Sort.by("fechaHora").descending());
        if (usuarioIdOrEmail.contains("@")) {
            return actividadRepo.findByEmail(usuarioIdOrEmail, pageable);
        } else {
            return actividadRepo.findByUsuarioId(usuarioIdOrEmail, pageable);
        }
    }

    @Override
    public List<Map<String, Object>> obtenerListaUsuariosSupervision(String busqueda) {
        List<Usuario> usuarios = usuarioRepo.findAll();
        List<Map<String, Object>> lista = new ArrayList<>();

        String query = busqueda != null ? busqueda.toLowerCase().trim() : "";

        for (Usuario u : usuarios) {
            String nombreCompleto = u.getNombreCompleto().toLowerCase();
            String email = u.getEmail() != null ? u.getEmail().toLowerCase() : "";

            if (!query.isEmpty() && !nombreCompleto.contains(query) && !email.contains(query)) {
                continue;
            }

            Map<String, Object> item = new HashMap<>();
            item.put("id", u.getId());
            item.put("nombre", u.getNombreCompleto());
            item.put("email", u.getEmail());
            item.put("rol", u.getRole() != null ? u.getRole().name() : "ROLE_USER");
            item.put("activo", u.isActivo());
            item.put("suspendido", u.isSuspendido());
            item.put("tipoSuspension", u.getTipoSuspension());
            item.put("fotoUrl", u.getFotoUrl() != null ? u.getFotoUrl() : u.getFotoPerfilUrl());

            // Determinar si está en línea
            PresenciaUsuario p = presenciaMap.get(email);
            boolean online = false;
            String seccion = "Inactivo";
            LocalDateTime ultima = null;

            if (p != null && p.getUltimaActividad() != null) {
                long seg = Duration.between(p.getUltimaActividad(), LocalDateTime.now()).getSeconds();
                if (seg < 90) {
                    online = true;
                }
                seccion = p.getSeccionActual();
                ultima = p.getUltimaActividad();
            }

            // Chequear sesiones
            for (UserSessionDetails sess : sessionTracker.getAllActiveSessions()) {
                if (sess.getUsername() != null && sess.getUsername().equalsIgnoreCase(u.getEmail())) {
                    online = true;
                    if (ultima == null) ultima = sess.getLastActivityTime();
                    break;
                }
            }

            item.put("online", online);
            item.put("seccion", seccion);
            item.put("ultimaActividad", ultima);
            item.put("tiempoRelativo", calcularTiempoRelativo(ultima));

            lista.add(item);
        }

        // Ordenar: primero los que están online, luego por orden alfabético
        lista.sort((a, b) -> {
            boolean aOnline = (boolean) a.get("online");
            boolean bOnline = (boolean) b.get("online");
            if (aOnline != bOnline) {
                return aOnline ? -1 : 1;
            }
            return ((String) a.get("nombre")).compareToIgnoreCase((String) b.get("nombre"));
        });

        return lista;
    }

    @Autowired
    private com.clinicaapp.service.IEmailService emailService;

    // Cache de sesiones de soporte activas (Impersonation delegada en memoria y auditada)
    private static final Map<String, SesionSoporteInfo> sesionesSoporteActivas = new ConcurrentHashMap<>();

    public static class SesionSoporteInfo {
        private String adminEmail;
        private String usuarioEmail;
        private String usuarioId;
        private LocalDateTime fechaInicio;
        private LocalDateTime fechaFin;
        private String motivo;

        public String getAdminEmail() { return adminEmail; }
        public void setAdminEmail(String adminEmail) { this.adminEmail = adminEmail; }
        public String getUsuarioEmail() { return usuarioEmail; }
        public void setUsuarioEmail(String usuarioEmail) { this.usuarioEmail = usuarioEmail; }
        public String getUsuarioId() { return usuarioId; }
        public void setUsuarioId(String usuarioId) { this.usuarioId = usuarioId; }
        public LocalDateTime getFechaInicio() { return fechaInicio; }
        public void setFechaInicio(LocalDateTime fechaInicio) { this.fechaInicio = fechaInicio; }
        public LocalDateTime getFechaFin() { return fechaFin; }
        public void setFechaFin(LocalDateTime fechaFin) { this.fechaFin = fechaFin; }
        public String getMotivo() { return motivo; }
        public void setMotivo(String motivo) { this.motivo = motivo; }
    }

    @Override
    public Map<String, Object> cerrarSesionesUsuario(String usuarioIdOrEmail, String adminEmail, String motivo, String ip) {
        Map<String, Object> res = new HashMap<>();
        Usuario usuario = buscarUsuario(usuarioIdOrEmail);
        if (usuario == null) {
            res.put("success", false);
            res.put("error", "Usuario no encontrado.");
            return res;
        }

        LocalDateTime ahora = LocalDateTime.now();
        usuario.setRevokedSessionsBefore(ahora);
        usuarioRepo.save(usuario);

        // Remover del tracker de sesiones en memoria
        try {
            sessionTracker.invalidarSesionUsuario(usuario.getEmail());
        } catch (Exception e) {}

        // Registrar en auditoría
        AuditoriaSupervision audit = new AuditoriaSupervision(
                adminEmail, "Super Administrador", usuario.getId(), usuario.getEmail(),
                usuario.getNombreCompleto(), "CIERRE_SESIONES",
                motivo != null ? motivo : "Cierre administrativo forzoso de sesiones",
                "Todas las sesiones anteriores a " + ahora + " fueron revocadas.",
                ip, null
        );
        auditoriaSupervisionRepo.save(audit);

        res.put("success", true);
        res.put("message", "Todas las sesiones activas de " + usuario.getNombreCompleto() + " fueron cerradas y revocadas exitosamente.");
        return res;
    }

    @Override
    public Map<String, Object> suspenderUsuario(String usuarioIdOrEmail, String adminEmail, String tipoSuspension, 
                                                Integer duracionMinutos, String motivo, String ip) {
        Map<String, Object> res = new HashMap<>();
        if (motivo == null || motivo.trim().isEmpty()) {
            res.put("success", false);
            res.put("error", "El motivo de la suspensión es estrictamente obligatorio.");
            return res;
        }

        Usuario usuario = buscarUsuario(usuarioIdOrEmail);
        if (usuario == null) {
            res.put("success", false);
            res.put("error", "Usuario no encontrado.");
            return res;
        }

        // Protección: No suspender a otro Super Admin
        if (usuario.getRole() == com.clinicaapp.model.enums.Role.ROLE_ADMIN) {
            res.put("success", false);
            res.put("error", "No está permitido suspender a un usuario con privilegios de Administrador.");
            return res;
        }

        LocalDateTime ahora = LocalDateTime.now();
        usuario.setSuspendido(true);
        usuario.setTipoSuspension("PERMANENTE".equalsIgnoreCase(tipoSuspension) ? "PERMANENTE" : "TEMPORAL");
        usuario.setMotivoSuspension(motivo.trim());
        usuario.setFechaInicioSuspension(ahora);
        usuario.setSuspendidoPorAdmin(adminEmail);
        usuario.setRevokedSessionsBefore(ahora); // Invalida sesiones activas inmediatamente

        if ("TEMPORAL".equalsIgnoreCase(usuario.getTipoSuspension())) {
            int mins = (duracionMinutos != null && duracionMinutos > 0) ? duracionMinutos : 60;
            usuario.setFechaFinSuspension(ahora.plusMinutes(mins));
        } else {
            usuario.setFechaFinSuspension(null);
        }

        usuarioRepo.save(usuario);

        // Desconectar sesiones
        cerrarSesionesUsuario(usuario.getId(), adminEmail, "Suspensión de cuenta aplicada", ip);

        // Auditoría
        AuditoriaSupervision audit = new AuditoriaSupervision(
                adminEmail, "Super Administrador", usuario.getId(), usuario.getEmail(),
                usuario.getNombreCompleto(), 
                "PERMANENTE".equalsIgnoreCase(usuario.getTipoSuspension()) ? "SUSPENSION_PERMANENTE" : "SUSPENSION_TEMPORAL",
                motivo,
                "Suspensión aplicada. Fin: " + (usuario.getFechaFinSuspension() != null ? usuario.getFechaFinSuspension().toString() : "Indefinida"),
                ip, duracionMinutos
        );
        auditoriaSupervisionRepo.save(audit);

        res.put("success", true);
        res.put("message", "La cuenta de " + usuario.getNombreCompleto() + " ha sido suspendida.");
        return res;
    }

    @Override
    public Map<String, Object> reactivarUsuario(String usuarioIdOrEmail, String adminEmail, String motivo, String ip) {
        Map<String, Object> res = new HashMap<>();
        Usuario usuario = buscarUsuario(usuarioIdOrEmail);
        if (usuario == null) {
            res.put("success", false);
            res.put("error", "Usuario no encontrado.");
            return res;
        }

        usuario.setSuspendido(false);
        usuario.setTipoSuspension(null);
        usuario.setMotivoSuspension(null);
        usuario.setFechaInicioSuspension(null);
        usuario.setFechaFinSuspension(null);
        usuario.setSuspendidoPorAdmin(null);
        usuarioRepo.save(usuario);

        AuditoriaSupervision audit = new AuditoriaSupervision(
                adminEmail, "Super Administrador", usuario.getId(), usuario.getEmail(),
                usuario.getNombreCompleto(), "REACTIVACION",
                motivo != null ? motivo : "Reactivación de cuenta autorizada por Super Admin",
                "Cuenta restaurada para acceso normal a ClínicaApp.",
                ip, null
        );
        auditoriaSupervisionRepo.save(audit);

        res.put("success", true);
        res.put("message", "La cuenta de " + usuario.getNombreCompleto() + " fue reactivada exitosamente.");
        return res;
    }

    @Override
    public Map<String, Object> dispararResetPasswordSeguro(String usuarioIdOrEmail, String adminEmail, String ip) {
        Map<String, Object> res = new HashMap<>();
        Usuario usuario = buscarUsuario(usuarioIdOrEmail);
        if (usuario == null) {
            res.put("success", false);
            res.put("error", "Usuario no encontrado.");
            return res;
        }

        try {
            String token = UUID.randomUUID().toString();
            usuario.setResetPasswordToken(token);
            usuario.setResetPasswordTokenExpiry(LocalDateTime.now().plusHours(2));
            usuarioRepo.save(usuario);

            // Detección dinámica de dominio / host de la aplicación
            String baseUrl = "https://clinica-app-fh9j.onrender.com";
            try {
                org.springframework.web.context.request.ServletRequestAttributes sra = 
                        (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder.getRequestAttributes();
                if (sra != null && sra.getRequest() != null) {
                    jakarta.servlet.http.HttpServletRequest req = sra.getRequest();
                    String scheme = req.getHeader("X-Forwarded-Proto");
                    if (scheme == null || scheme.isBlank()) scheme = req.getScheme();
                    String host = req.getHeader("X-Forwarded-Host");
                    if (host == null || host.isBlank()) host = req.getHeader("Host");
                    if (host == null || host.isBlank()) host = req.getServerName() + (req.getServerPort() == 80 || req.getServerPort() == 443 ? "" : ":" + req.getServerPort());
                    baseUrl = scheme + "://" + host;
                }
            } catch (Exception ignored) {}

            String enlaceReset = baseUrl + "/reset-password?token=" + token;

            String cuerpoHtml = "<!DOCTYPE html>"
                    + "<html lang='es'>"
                    + "<head>"
                    + "<meta charset='UTF-8'>"
                    + "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
                    + "<title>Restablecimiento de Contraseña</title>"
                    + "</head>"
                    + "<body style='margin:0; padding:0; background-color:#f8fafc; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif;'>"
                    + "<table role='presentation' width='100%' cellspacing='0' cellpadding='0' border='0' style='background-color:#f8fafc; padding: 40px 15px;'>"
                    + "  <tr>"
                    + "    <td align='center'>"
                    + "      <table role='presentation' width='100%' style='max-width: 580px; background-color:#ffffff; border-radius: 20px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.06); border: 1px solid #e2e8f0;' cellspacing='0' cellpadding='0' border='0'>"
                    + "        <!-- Encabezado con degradado de marca -->"
                    + "        <tr>"
                    + "          <td style='background: linear-gradient(135deg, #6366f1 0%, #4f46e5 50%, #0284c7 100%); padding: 36px 30px; text-align: center; color: #ffffff;'>"
                    + "            <div style='background: rgba(255,255,255,0.2); width: 64px; height: 64px; border-radius: 50%; margin: 0 auto 16px; line-height: 64px; font-size: 30px; border: 2px solid rgba(255,255,255,0.35);'>🛡️</div>"
                    + "            <h1 style='margin: 0; font-size: 24px; font-weight: 800; letter-spacing: -0.5px;'>ClínicaApp Seguridad</h1>"
                    + "            <p style='margin: 6px 0 0; font-size: 14px; opacity: 0.9;'>Gestión de Credenciales de Acceso</p>"
                    + "          </td>"
                    + "        </tr>"
                    + "        <!-- Cuerpo del mensaje -->"
                    + "        <tr>"
                    + "          <td style='padding: 36px 32px; color: #334155; font-size: 15px; line-height: 1.6;'>"
                    + "            <p style='margin-top: 0; font-size: 16px; font-weight: 700; color: #0f172a;'>Estimado/a " + usuario.getNombreCompleto() + ",</p>"
                    + "            <p>Por solicitud administrativa del <strong>Super Administrador</strong> de ClínicaApp, se ha generado una autorización segura para que puedas establecer una nueva contraseña de acceso.</p>"
                    + "            <!-- Call to action button -->"
                    + "            <div style='text-align: center; margin: 32px 0;'>"
                    + "              <a href='" + enlaceReset + "' target='_blank' style='display: inline-block; background: linear-gradient(135deg, #4f46e5, #0284c7); color: #ffffff; text-decoration: none; padding: 15px 36px; border-radius: 12px; font-weight: 800; font-size: 15px; box-shadow: 0 6px 20px rgba(79, 70, 229, 0.35);'>Restablecer Mi Contraseña</a>"
                    + "            </div>"
                    + "            <!-- Aviso de seguridad -->"
                    + "            <div style='background: #f1f5f9; border-left: 4px solid #0284c7; padding: 14px 16px; border-radius: 8px; margin: 24px 0 16px; font-size: 13.5px; color: #475569;'>"
                    + "              ⏱️ <strong>Validez:</strong> Este enlace expirará automáticamente en <strong>2 horas</strong> por protocolos de ciberseguridad.<br>"
                    + "              🔒 Si el botón no abre directamente, copia y pega la siguiente URL en tu navegador:<br>"
                    + "              <a href='" + enlaceReset + "' style='color: #0284c7; word-break: break-all; font-size: 12px;'>" + enlaceReset + "</a>"
                    + "            </div>"
                    + "            <p style='font-size: 13px; color: #64748b; margin-bottom: 0;'>Si tú no solicitaste este cambio o tienes dudas, puedes ignorar este correo de forma segura o contactar al soporte de la plataforma.</p>"
                    + "          </td>"
                    + "        </tr>"
                    + "        <!-- Pie de página -->"
                    + "        <tr>"
                    + "          <td style='background-color: #f8fafc; border-top: 1px solid #e2e8f0; padding: 20px 32px; text-align: center; color: #94a3b8; font-size: 12px;'>"
                    + "            <p style='margin: 0;'>© 2026 ClínicaApp. Todos los derechos reservados.</p>"
                    + "            <p style='margin: 4px 0 0;'>Servicio de autenticación y seguridad en la nube.</p>"
                    + "          </td>"
                    + "        </tr>"
                    + "      </table>"
                    + "    </td>"
                    + "  </tr>"
                    + "</table>"
                    + "</body>"
                    + "</html>";

            emailService.sendSimpleMessage(usuario.getEmail(), "Restablecimiento de Contraseña Seguro - ClínicaApp", cuerpoHtml);

            AuditoriaSupervision audit = new AuditoriaSupervision(
                    adminEmail, "Super Administrador", usuario.getId(), usuario.getEmail(),
                    usuario.getNombreCompleto(), "RESET_PASSWORD_TRIGGER",
                    "Envío seguro de enlace de recuperación de contraseña",
                    "Token seguro despachado al correo registrado del usuario con plantilla HTML corporativa.",
                    ip, null
            );
            auditoriaSupervisionRepo.save(audit);

            res.put("success", true);
            res.put("message", "Enlace de recuperación seguro enviado exitosamente al correo " + usuario.getEmail());
            return res;
        } catch (Exception e) {
            res.put("success", false);
            res.put("error", "Error al procesar el restablecimiento: " + e.getMessage());
            return res;
        }
    }

    @Override
    public Map<String, Object> iniciarSesionSoporte(String usuarioIdOrEmail, String adminEmail, String motivo, Integer duracionMinutos, String ip) {
        Map<String, Object> res = new HashMap<>();
        Usuario usuario = buscarUsuario(usuarioIdOrEmail);
        if (usuario == null) {
            res.put("success", false);
            res.put("error", "Usuario no encontrado.");
            return res;
        }

        if (usuario.getRole() == com.clinicaapp.model.enums.Role.ROLE_ADMIN) {
            res.put("success", false);
            res.put("error", "Por políticas de seguridad, no se puede iniciar sesión de soporte sobre otra cuenta de Administrador.");
            return res;
        }

        int mins = (duracionMinutos != null && duracionMinutos > 0) ? Math.min(duracionMinutos, 30) : 15;
        LocalDateTime inicio = LocalDateTime.now();
        LocalDateTime fin = inicio.plusMinutes(mins);

        SesionSoporteInfo sesion = new SesionSoporteInfo();
        sesion.setAdminEmail(adminEmail);
        sesion.setUsuarioEmail(usuario.getEmail());
        sesion.setUsuarioId(usuario.getId());
        sesion.setFechaInicio(inicio);
        sesion.setFechaFin(fin);
        sesion.setMotivo(motivo != null ? motivo : "Soporte técnico administrativo autorizado");

        sesionesSoporteActivas.put(adminEmail.toLowerCase(), sesion);

        AuditoriaSupervision audit = new AuditoriaSupervision(
                adminEmail, "Super Administrador", usuario.getId(), usuario.getEmail(),
                usuario.getNombreCompleto(), "SESION_SOPORTE_INICIO",
                sesion.getMotivo(),
                "Inicio de sesión delegada de soporte. Duración autorizada: " + mins + " minutos.",
                ip, mins
        );
        auditoriaSupervisionRepo.save(audit);

        res.put("success", true);
        res.put("message", "Sesión de soporte iniciada correctamente.");
        res.put("duracionMinutos", mins);
        res.put("fechaFin", fin);
        res.put("usuarioEmail", usuario.getEmail());
        res.put("usuarioNombre", usuario.getNombreCompleto());
        res.put("redirectUrl", "/usuario/dashboard");
        return res;
    }

    @Override
    public Map<String, Object> finalizarSesionSoporte(String usuarioIdOrEmail, String adminEmail, String ip) {
        Map<String, Object> res = new HashMap<>();
        SesionSoporteInfo sesion = sesionesSoporteActivas.remove(adminEmail.toLowerCase());

        String uid = usuarioIdOrEmail;
        String uemail = usuarioIdOrEmail;
        String unombre = "Usuario";

        if (sesion != null) {
            uid = sesion.getUsuarioId();
            uemail = sesion.getUsuarioEmail();
        } else {
            Usuario u = buscarUsuario(usuarioIdOrEmail);
            if (u != null) {
                uid = u.getId();
                uemail = u.getEmail();
                unombre = u.getNombreCompleto();
            }
        }

        AuditoriaSupervision audit = new AuditoriaSupervision(
                adminEmail, "Super Administrador", uid, uemail,
                unombre, "SESION_SOPORTE_FIN",
                "Finalización voluntaria o por expiración de la sesión de soporte",
                "Contexto de Super Administrador restaurado completamente.",
                ip, null
        );
        auditoriaSupervisionRepo.save(audit);

        res.put("success", true);
        res.put("message", "Sesión de soporte finalizada.");
        res.put("redirectUrl", "/admin/supervision" + (uid != null ? "?usuarioId=" + uid : ""));
        return res;
    }

    @Override
    public Map<String, Object> obtenerSesionSoporteActiva(String adminEmail) {
        if (adminEmail == null || adminEmail.isBlank()) return null;
        SesionSoporteInfo sesion = sesionesSoporteActivas.get(adminEmail.toLowerCase());
        if (sesion == null) return null;

        // Validar expiración en backend
        if (LocalDateTime.now().isAfter(sesion.getFechaFin())) {
            sesionesSoporteActivas.remove(adminEmail.toLowerCase());
            // Registrar auto-expiración en auditoría
            AuditoriaSupervision audit = new AuditoriaSupervision(
                    adminEmail, "Super Administrador", sesion.getUsuarioId(), sesion.getUsuarioEmail(),
                    "Usuario", "SESION_SOPORTE_EXPIRADA",
                    "Expiración automática por límite de tiempo (15 min)",
                    "Sesión delegada concluida por tiempo máximo.",
                    "127.0.0.1", null
            );
            auditoriaSupervisionRepo.save(audit);
            return null;
        }

        Map<String, Object> map = new HashMap<>();
        map.put("activa", true);
        map.put("usuarioEmail", sesion.getUsuarioEmail());
        map.put("usuarioId", sesion.getUsuarioId());
        map.put("adminEmail", sesion.getAdminEmail());
        map.put("fechaInicio", sesion.getFechaInicio());
        map.put("fechaFin", sesion.getFechaFin());
        map.put("motivo", sesion.getMotivo());
        return map;
    }

    @Override
    public List<AuditoriaSupervision> obtenerAuditoriasUsuario(String usuarioIdOrEmail) {
        if (usuarioIdOrEmail == null || usuarioIdOrEmail.isBlank()) return Collections.emptyList();
        Usuario u = buscarUsuario(usuarioIdOrEmail);
        if (u != null) {
            List<AuditoriaSupervision> list = auditoriaSupervisionRepo.findByUsuarioAfectadoIdOrderByFechaHoraDesc(u.getId());
            if (list.isEmpty()) {
                list = auditoriaSupervisionRepo.findByUsuarioAfectadoEmailOrderByFechaHoraDesc(u.getEmail());
            }
            return list;
        }
        return auditoriaSupervisionRepo.findByUsuarioAfectadoEmailOrderByFechaHoraDesc(usuarioIdOrEmail);
    }

    private Usuario buscarUsuario(String term) {
        if (term == null || term.isBlank()) return null;
        String t = term.trim();
        if (t.contains("@")) {
            Usuario u = usuarioRepo.findByEmail(t);
            if (u == null) u = usuarioRepo.findByEmail(t.toLowerCase());
            return u;
        } else {
            return usuarioRepo.findById(t).orElse(usuarioRepo.findByEmail(t));
        }
    }

    private String calcularTiempoRelativo(LocalDateTime fecha) {
        if (fecha == null) return "Sin actividad reciente";
        Duration duration = Duration.between(fecha, LocalDateTime.now());
        long segundos = duration.getSeconds();
        if (segundos < 5) return "Hace unos segundos";
        if (segundos < 60) return "Hace " + segundos + " segundos";
        long minutos = segundos / 60;
        if (minutos < 60) return "Hace " + minutos + (minutos == 1 ? " minuto" : " minutos");
        long horas = minutos / 60;
        if (horas < 24) return "Hace " + horas + (horas == 1 ? " hora" : " horas");
        long dias = horas / 24;
        return "Hace " + dias + (dias == 1 ? " día" : " días");
    }
}
