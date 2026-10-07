package com.clinicaapp.service.impl;

import com.clinicaapp.model.Usuario;
import com.clinicaapp.model.UsuarioActividad;
import com.clinicaapp.model.UserSessionDetails;
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
