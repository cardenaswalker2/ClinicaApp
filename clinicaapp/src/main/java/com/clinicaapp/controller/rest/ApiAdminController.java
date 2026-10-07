package com.clinicaapp.controller.rest;

import com.clinicaapp.model.*;
import com.clinicaapp.model.enums.EstadoClinica;
import com.clinicaapp.model.enums.EstadoPublicacion;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.repository.ClinicaRepository;
import com.clinicaapp.repository.ConfiguracionRepository;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class ApiAdminController {

    private static final String CORE_KEY = "1428";

    @Autowired private UsuarioRepository usuarioRepository;
    @Autowired private IUsuarioService usuarioService;
    @Autowired private IClinicaService clinicaService;
    @Autowired private ClinicaRepository clinicaRepository;
    @Autowired private ICitaService citaService;
    @Autowired private IServicioService servicioService;
    @Autowired private ConfiguracionRepository configRepo;
    @Autowired private LogActividadService logActividadService;
    @Autowired private ComunidadPetService comunidadPetService;
    @Autowired private IOptimizacionService optimizacionService;

    // ── Helper de validación de Super Administrador ──
    private boolean isSuperAdmin(String email) {
        if (email == null || email.isBlank()) return false;
        Usuario u = usuarioRepository.findByEmail(email);
        return u != null && u.getRole() == Role.ROLE_ADMIN && u.isActivo();
    }

    // ── 1. VERIFICACIÓN DE CÓDIGO CORE (1428) ──
    @PostMapping("/verify-core-key")
    public ResponseEntity<?> verifyCoreKey(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");
        String coreKey = payload.get("coreKey");

        if (!isSuperAdmin(email)) {
            logActividadService.registrarAuto("Intento no autorizado a Super Admin Hub", "SEGURIDAD", "DANGER", "Email no admin: " + email);
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("success", false, "message", "Acceso denegado. Permisos insuficientes."));
        }

        if (CORE_KEY.equals(coreKey != null ? coreKey.trim() : "")) {
            logActividadService.registrarAuto("Acceso concedido a Super Admin Hub Móvil", "SEGURIDAD", "SUCCESS", "Admin: " + email);
            return ResponseEntity.ok(Map.of("success", true, "message", "Acceso autorizado al Super Admin Hub"));
        } else {
            logActividadService.registrarAuto("Código CORE incorrecto en acceso móvil", "SEGURIDAD", "WARNING", "Admin: " + email);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("success", false, "message", "Acceso denegado. Código CORE incorrecto."));
        }
    }

    // ── 2. DASHBOARD & MÉTRICAS SAAS ──
    @GetMapping("/dashboard")
    public ResponseEntity<?> getDashboardMetrics(@RequestParam String email) {
        if (!isSuperAdmin(email)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Acceso no autorizado");
        }

        List<Cita> todasLasCitas = citaService.findAll();
        List<Usuario> todosLosUsuarios = usuarioService.findAllUsers();
        List<Clinica> todasLasClinicas = clinicaService.findAll();

        double totalIngresos = todasLasCitas.stream()
                .filter(c -> "PAGADO".equalsIgnoreCase(c.getEstadoPago()))
                .mapToDouble(c -> c.getCosto() != null ? c.getCosto() : 0.0)
                .sum();

        double mrr = 0.0;
        int countStarter = 0, countProfessional = 0, countEnterprise = 0;
        for (Clinica c : todasLasClinicas) {
            if ("Activo".equalsIgnoreCase(c.getEstadoSuscripcion()) || "Prueba".equalsIgnoreCase(c.getEstadoSuscripcion())) {
                String plan = c.getPlanSaaS() != null ? c.getPlanSaaS() : "Starter";
                if ("Starter".equalsIgnoreCase(plan)) { mrr += 49.0; countStarter++; }
                else if ("Professional".equalsIgnoreCase(plan)) { mrr += 99.0; countProfessional++; }
                else if ("Enterprise".equalsIgnoreCase(plan)) { mrr += 199.0; countEnterprise++; }
            }
        }
        double arr = mrr * 12;

        long solicitudesPendientes = clinicaService.buscarPorEstado(EstadoClinica.PENDIENTE).size();
        long adopcionesPendientes = comunidadPetService.getPendingApproval().size();

        Map<String, Object> data = new HashMap<>();
        data.put("totalUsuarios", todosLosUsuarios.size());
        data.put("totalClinicas", todasLasClinicas.size());
        data.put("totalCitas", todasLasCitas.size());
        data.put("totalIngresos", totalIngresos);
        data.put("mrr", mrr);
        data.put("arr", arr);
        data.put("countStarter", countStarter);
        data.put("countProfessional", countProfessional);
        data.put("countEnterprise", countEnterprise);
        data.put("solicitudesPendientes", solicitudesPendientes);
        data.put("adopcionesPendientes", adopcionesPendientes);

        return ResponseEntity.ok(data);
    }

    // ── 3. CENTRO DE CONTROL E INFRAESTRUCTURA ──
    @GetMapping("/centro-control")
    public ResponseEntity<?> getCentroControl(@RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS").orElse(new ConfiguracionGlobal());
        return ResponseEntity.ok(config);
    }

    @PostMapping("/centro-control")
    public ResponseEntity<?> updateCentroControl(@RequestParam String email, @RequestBody ConfiguracionGlobal config) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        ConfiguracionGlobal actual = configRepo.findById("GLOBAL_SETTINGS").orElse(new ConfiguracionGlobal());

        actual.setModoMantenimiento(config.isModoMantenimiento());
        actual.setMinutosParaCierre(config.getMinutosParaCierre());
        actual.setSistemaActivo(config.isSistemaActivo());
        actual.setBroadcastActivo(config.isBroadcastActivo());
        actual.setBroadcastColor(config.getBroadcastColor());
        actual.setMensajeGlobal(config.getMensajeGlobal());
        actual.setId("GLOBAL_SETTINGS");

        configRepo.save(actual);
        logActividadService.registrarAuto("Infraestructura actualizada desde App Móvil", "CONFIGURACION", "INFO", "Admin: " + email);
        return ResponseEntity.ok(Map.of("success", true, "message", "Infraestructura actualizada"));
    }

    // ── 4. GESTIÓN DE CLÍNICAS & SOLICITUDES ──
    @GetMapping("/clinicas")
    public ResponseEntity<?> getClinicas(@RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return ResponseEntity.ok(clinicaService.findAll());
    }

    @PostMapping("/clinicas")
    public ResponseEntity<?> crearClinica(@RequestParam String email, @RequestBody Map<String, Object> payload) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        try {
            com.clinicaapp.dto.AdminClinicaDTO dto = new com.clinicaapp.dto.AdminClinicaDTO();
            dto.setNombre(payload.getOrDefault("nombre", "").toString());
            dto.setDireccion(payload.getOrDefault("direccion", "").toString());
            dto.setTelefono(payload.getOrDefault("telefono", "").toString());
            dto.setEmail(payload.getOrDefault("email", "").toString());
            dto.setDescripcion(payload.getOrDefault("descripcion", "").toString());
            dto.setNombreDuenio(payload.getOrDefault("nombreDuenio", "Admin").toString());
            dto.setApellidoDuenio(payload.getOrDefault("apellidoDuenio", "Sede").toString());
            dto.setEmailDuenio(payload.getOrDefault("emailDuenio", dto.getEmail()).toString());
            dto.setPasswordDuenio(payload.getOrDefault("passwordDuenio", "clinica123").toString());

            clinicaService.saveAdmin(dto, null);
            logActividadService.registrarAuto("Sede clínica creada desde Móvil", "CLINICAS", "SUCCESS", "Clínica: " + dto.getNombre());
            return ResponseEntity.ok(Map.of("success", true, "message", "Clínica creada exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PutMapping("/clinicas/{id}")
    public ResponseEntity<?> editarClinica(@PathVariable String id, @RequestParam String email, @RequestBody Map<String, Object> payload) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return clinicaRepository.findById(id).map(c -> {
            if (payload.containsKey("nombre")) c.setNombre(payload.get("nombre").toString());
            if (payload.containsKey("direccion")) c.setDireccion(payload.get("direccion").toString());
            if (payload.containsKey("telefono")) c.setTelefono(payload.get("telefono").toString());
            if (payload.containsKey("email")) c.setEmail(payload.get("email").toString());
            if (payload.containsKey("descripcion")) c.setDescripcion(payload.get("descripcion").toString());
            if (payload.containsKey("horaApertura")) c.setHoraApertura(payload.get("horaApertura").toString());
            if (payload.containsKey("horaCierre")) c.setHoraCierre(payload.get("horaCierre").toString());
            if (payload.containsKey("latitud")) c.setLatitud(Double.parseDouble(payload.get("latitud").toString()));
            if (payload.containsKey("longitud")) c.setLongitud(Double.parseDouble(payload.get("longitud").toString()));
            if (payload.containsKey("planSaaS")) c.setPlanSaaS(payload.get("planSaaS").toString());

            clinicaRepository.save(c);
            logActividadService.registrarAuto("Sede clínica editada desde Móvil", "CLINICAS", "INFO", "Clínica ID: " + id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Clínica actualizada exitosamente"));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/clinicas/{id}")
    public ResponseEntity<?> eliminarClinica(@PathVariable String id, @RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        try {
            clinicaService.deleteById(id);
            logActividadService.registrarAuto("Sede clínica eliminada desde Móvil", "CLINICAS", "WARNING", "Clínica ID: " + id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Clínica eliminada exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/clinicas/{id}/aprobar")
    public ResponseEntity<?> aprobarClinica(@PathVariable String id, @RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        try {
            clinicaService.aprobarClinica(id);
            logActividadService.registrarAuto("Sede aprobada desde Móvil", "CLINICAS", "SUCCESS", "Clínica ID: " + id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Clínica aprobada"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/clinicas/{id}/rechazar")
    public ResponseEntity<?> rechazarClinica(@PathVariable String id, @RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        try {
            clinicaService.rechazarClinica(id);
            logActividadService.registrarAuto("Sede rechazada desde Móvil", "CLINICAS", "WARNING", "Clínica ID: " + id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Clínica rechazada"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/clinicas/{id}/plan")
    public ResponseEntity<?> updatePlanSaaS(@PathVariable String id, @RequestParam String email, @RequestBody Map<String, Object> payload) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return clinicaRepository.findById(id).map(c -> {
            if (payload.containsKey("plan")) c.setPlanSaaS(payload.get("plan").toString());
            if (payload.containsKey("estadoSuscripcion")) c.setEstadoSuscripcion(payload.get("estadoSuscripcion").toString());
            if (payload.containsKey("diasGratis")) {
                int dias = Integer.parseInt(payload.get("diasGratis").toString());
                LocalDate venc = c.getFechaVencimientoPlan() != null ? c.getFechaVencimientoPlan() : LocalDate.now();
                c.setFechaVencimientoPlan(venc.plusDays(dias));
            }
            clinicaRepository.save(c);
            return ResponseEntity.ok(Map.of("success", true, "message", "Suscripción actualizada"));
        }).orElse(ResponseEntity.notFound().build());
    }

    // ── 5. GESTIÓN DE USUARIOS (CRUD COMPLETO) ──
    @GetMapping("/usuarios")
    public ResponseEntity<?> getUsuarios(@RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return ResponseEntity.ok(usuarioService.findAllUsers());
    }

    @PostMapping("/usuarios")
    public ResponseEntity<?> crearUsuario(@RequestParam String email, @RequestBody Map<String, String> payload) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        try {
            String uEmail = payload.get("email");
            if (uEmail == null || uEmail.isBlank()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "error", "El correo es obligatorio"));
            }
            if (usuarioService.findByEmail(uEmail) != null) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "error", "El correo ya está registrado"));
            }

            com.clinicaapp.dto.UsuarioRegistroDTO dto = new com.clinicaapp.dto.UsuarioRegistroDTO();
            dto.setNombre(payload.getOrDefault("nombre", "Usuario"));
            dto.setApellido(payload.getOrDefault("apellido", ""));
            dto.setEmail(uEmail);
            dto.setPassword(payload.getOrDefault("password", "clinica123"));
            dto.setTelefono(payload.getOrDefault("telefono", ""));

            Role rolSeleccionado = Role.ROLE_USER;
            String rolStr = payload.get("role");
            if (rolStr != null) {
                try { rolSeleccionado = Role.valueOf(rolStr); } catch (Exception ignored) {}
            }
            dto.setRole(rolSeleccionado);

            usuarioService.createUsuarioWithRole(dto, rolSeleccionado);
            logActividadService.registrarAuto("Usuario creado desde Móvil", "USUARIOS", "SUCCESS", "Email: " + uEmail + " | Rol: " + rolSeleccionado);
            return ResponseEntity.ok(Map.of("success", true, "message", "Usuario creado exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PutMapping("/usuarios/{id}")
    public ResponseEntity<?> editarUsuario(@PathVariable String id, @RequestParam String email, @RequestBody Map<String, String> payload) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return usuarioRepository.findById(id).map(u -> {
            if (payload.containsKey("nombre")) u.setNombre(payload.get("nombre"));
            if (payload.containsKey("apellido")) u.setApellido(payload.get("apellido"));
            if (payload.containsKey("telefono")) u.setTelefono(payload.get("telefono"));
            if (payload.containsKey("direccion")) u.setDireccion(payload.get("direccion"));
            if (payload.containsKey("role")) {
                try { u.setRole(Role.valueOf(payload.get("role"))); } catch (Exception ignored) {}
            }
            usuarioRepository.save(u);
            logActividadService.registrarAuto("Usuario actualizado desde Móvil", "USUARIOS", "INFO", "Usuario ID: " + id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Usuario actualizado exitosamente"));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/usuarios/{id}")
    public ResponseEntity<?> eliminarUsuario(@PathVariable String id, @RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        try {
            usuarioService.deleteById(id);
            logActividadService.registrarAuto("Usuario eliminado desde Móvil", "USUARIOS", "WARNING", "Usuario ID: " + id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Usuario eliminado exitosamente"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/usuarios/{id}/toggle-status")
    public ResponseEntity<?> toggleUsuarioStatus(@PathVariable String id, @RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return usuarioRepository.findById(id).map(u -> {
            u.setActivo(!u.isActivo());
            usuarioRepository.save(u);
            logActividadService.registrarAuto("Estado de usuario modificado desde Móvil", "USUARIOS", "INFO", "Usuario: " + u.getEmail() + " | Activo: " + u.isActivo());
            return ResponseEntity.ok(Map.of("success", true, "activo", u.isActivo()));
        }).orElse(ResponseEntity.notFound().build());
    }

    // ── 6. TELEMETRÍA Y SALUD DEL SISTEMA (UPTIME REAL) ──
    @GetMapping("/salud")
    public ResponseEntity<?> getSaludSistema(@RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");

        double cpu = 5.4;
        try {
            java.lang.management.OperatingSystemMXBean osBean = java.lang.management.ManagementFactory.getOperatingSystemMXBean();
            if (osBean instanceof com.sun.management.OperatingSystemMXBean) {
                cpu = ((com.sun.management.OperatingSystemMXBean) osBean).getCpuLoad() * 100.0;
            }
        } catch (Exception ignored) {}
        if (cpu < 0 || Double.isNaN(cpu)) cpu = 6.2;

        Runtime runtime = Runtime.getRuntime();
        double totalMemoryGb = runtime.totalMemory() / (1024.0 * 1024.0 * 1024.0);
        double freeMemoryGb = runtime.freeMemory() / (1024.0 * 1024.0 * 1024.0);
        double usedMemoryGb = totalMemoryGb - freeMemoryGb;

        boolean mongoOk = false;
        try {
            configRepo.count();
            mongoOk = true;
        } catch (Exception ignored) {}

        // Uptime real calculado dinámicamente desde la JVM
        long uptimeMs = java.lang.management.ManagementFactory.getRuntimeMXBean().getUptime();
        long seconds = (uptimeMs / 1000) % 60;
        long minutes = (uptimeMs / (1000 * 60)) % 60;
        long hours = (uptimeMs / (1000 * 60 * 60)) % 24;
        long days = (uptimeMs / (1000 * 60 * 60 * 24));
        String uptimeStr = days > 0 ? String.format("%dd %02dh %02dm", days, hours, minutes)
                                   : String.format("%02dh %02dm %02ds", hours, minutes, seconds);

        Map<String, Object> salud = new HashMap<>();
        salud.put("cpuUsage", String.format("%.1f%%", cpu));
        salud.put("totalMemory", String.format("%.2f GB", totalMemoryGb));
        salud.put("usedMemory", String.format("%.2f GB", usedMemoryGb));
        salud.put("freeMemory", String.format("%.2f GB", freeMemoryGb));
        salud.put("mongoOk", mongoOk);
        salud.put("mongoStatus", mongoOk ? "OPERATIVO" : "ERROR");
        salud.put("uptime", uptimeStr);

        return ResponseEntity.ok(salud);
    }


    // ── 7. AUDITORÍA Y REGISTROS ──
    @GetMapping("/auditoria")
    public ResponseEntity<?> getAuditoria(@RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return ResponseEntity.ok(logActividadService.obtenerUltimos5());
    }

    @PostMapping("/auditoria/limpiar")
    public ResponseEntity<?> limpiarAuditoria(@RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        logActividadService.limpiarLogs();
        logActividadService.registrarAuto("Auditoría vaciada desde App Móvil", "SEGURIDAD", "WARNING", "Admin: " + email);
        return ResponseEntity.ok(Map.of("success", true, "message", "Auditoría vaciada exitosamente"));
    }

    // ── 8. MODERACIÓN DE ADOPCIONES ──
    @GetMapping("/comunidad/pendientes")
    public ResponseEntity<?> getAdopcionesPendientes(@RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return ResponseEntity.ok(comunidadPetService.getPendingApproval());
    }

    @PostMapping("/comunidad/{id}/aprobar")
    public ResponseEntity<?> aprobarAdopcion(@PathVariable String id, @RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return comunidadPetService.getById(id).map(p -> {
            p.setEstado(EstadoPublicacion.DISPONIBLE);
            comunidadPetService.save(p);
            return ResponseEntity.ok(Map.of("success", true, "message", "Publicación aprobada"));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/comunidad/{id}/rechazar")
    public ResponseEntity<?> rechazarAdopcion(@PathVariable String id, @RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return comunidadPetService.getById(id).map(p -> {
            p.setEstado(EstadoPublicacion.RECHAZADO);
            comunidadPetService.save(p);
            return ResponseEntity.ok(Map.of("success", true, "message", "Publicación rechazada"));
        }).orElse(ResponseEntity.notFound().build());
    }

    // ── 9. SERVICIOS MAESTROS ──
    @GetMapping("/servicios")
    public ResponseEntity<?> getServiciosMaestros(@RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        return ResponseEntity.ok(servicioService.findAll());
    }

    @PostMapping("/servicios")
    public ResponseEntity<?> guardarServicioMaestro(@RequestParam String email, @RequestBody Servicio servicio) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        try {
            servicioService.save(servicio);
            logActividadService.registrarAuto("Servicio maestro guardado desde Móvil", "SERVICIOS", "SUCCESS", "Servicio: " + servicio.getNombre());
            return ResponseEntity.ok(Map.of("success", true, "message", "Servicio maestro guardado"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/servicios/{id}/eliminar")
    public ResponseEntity<?> eliminarServicioMaestro(@PathVariable String id, @RequestParam String email) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        try {
            servicioService.deleteById(id);
            logActividadService.registrarAuto("Servicio maestro eliminado desde Móvil", "SERVICIOS", "WARNING", "Servicio ID: " + id);
            return ResponseEntity.ok(Map.of("success", true, "message", "Servicio maestro eliminado"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    // ── 10. PLEB + HAVERSINE GLOBAL ──
    @GetMapping("/optimizacion-global")
    public ResponseEntity<?> optimizacionGlobal(
            @RequestParam String email,
            @RequestParam(defaultValue = "4.6097") double lat,
            @RequestParam(defaultValue = "-74.0817") double lon,
            @RequestParam(defaultValue = "50.0") double radioKm,
            @RequestParam(defaultValue = "1.0") double pesoDistancia,
            @RequestParam(defaultValue = "1.0") double pesoPrecio,
            @RequestParam(defaultValue = "1.0") double pesoCalificacion) {
        if (!isSuperAdmin(email)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        try {
            var resultado = optimizacionService.resolverOptimizacion(lat, lon, radioKm, "Super Admin Global Console");
            return ResponseEntity.ok(resultado);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
