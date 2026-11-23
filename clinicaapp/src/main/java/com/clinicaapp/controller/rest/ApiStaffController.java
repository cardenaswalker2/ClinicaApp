package com.clinicaapp.controller.rest;

import com.clinicaapp.model.*;
import com.clinicaapp.repository.*;
import com.clinicaapp.service.IProductoService;
import com.clinicaapp.service.IServicioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/staff")
@CrossOrigin(origins = "*")
public class ApiStaffController {

    @Autowired private UsuarioRepository usuarioRepository;
    @Autowired private ClinicaRepository clinicaRepository;
    @Autowired private CitaRepository citaRepository;
    @Autowired private MascotaRepository mascotaRepository;
    @Autowired private VisitaRepository visitaRepository;
    @Autowired private IProductoService productoService;
    @Autowired private IServicioService servicioService;

    private String resolveClinicaId(Usuario user) {
        if (user == null) return null;
        if (user.getClinicaId() != null && !user.getClinicaId().isBlank()) {
            return user.getClinicaId();
        }
        Clinica owned = clinicaRepository.findByUsuarioAdminId(user.getId());
        if (owned != null) return owned.getId();
        Clinica byEmail = clinicaRepository.findByEmail(user.getEmail());
        return byEmail != null ? byEmail.getId() : null;
    }

    @GetMapping("/dashboard")
    public ResponseEntity<?> getDashboard(@RequestParam String email) {
        Usuario user = usuarioRepository.findByEmail(email);
        if (user == null) return ResponseEntity.notFound().build();

        String clinicaId = resolveClinicaId(user);
        Clinica clinica = clinicaId != null ? clinicaRepository.findById(clinicaId).orElse(null) : null;

        List<Cita> citas = clinicaId != null ? citaRepository.findByClinicaId(clinicaId) : List.of();
        citas.sort((a, b) -> {
            LocalDateTime fa = a.getFechaHora() != null ? a.getFechaHora() : LocalDateTime.MIN;
            LocalDateTime fb = b.getFechaHora() != null ? b.getFechaHora() : LocalDateTime.MIN;
            return fb.compareTo(fa);
        });

        List<Map<String, Object>> citasEnriquecidas = citas.stream().limit(50).map(c -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id", c.getId());
            m.put("fechaHora", c.getFechaHora() != null ? c.getFechaHora().toString() : "");
            m.put("motivo", c.getMotivo() != null ? c.getMotivo() : "Consulta");
            m.put("estado", c.getEstado() != null ? c.getEstado() : "Pendiente");
            m.put("estadoPago", c.getEstadoPago() != null ? c.getEstadoPago() : "PENDIENTE");
            m.put("costo", c.getCosto() != null ? c.getCosto() : 0.0);
            m.put("mascotaId", c.getMascotaId());
            m.put("clinicaId", c.getClinicaId());
            mascotaRepository.findById(c.getMascotaId() != null ? c.getMascotaId() : "")
                    .ifPresent(pet -> m.put("mascotaNombre", pet.getNombre()));
            usuarioRepository.findById(c.getUsuarioId() != null ? c.getUsuarioId() : "")
                    .ifPresent(owner -> m.put("propietarioNombre", owner.getNombre()));
            return m;
        }).collect(Collectors.toList());

        long pendientes = citas.stream().filter(c -> "PENDIENTE".equalsIgnoreCase(c.getEstado())).count();
        long confirmadas = citas.stream().filter(c -> "CONFIRMADA".equalsIgnoreCase(c.getEstado())).count();
        long completadas = citas.stream().filter(c -> "COMPLETADA".equalsIgnoreCase(c.getEstado())).count();

        Map<String, Object> res = new HashMap<>();
        res.put("clinicaNombre", clinica != null ? clinica.getNombre() : "Sede ClinicaApp");
        res.put("clinicaId", clinicaId != null ? clinicaId : "");
        res.put("rol", user.getRole() != null ? user.getRole().name() : "ROLE_CLINICA");
        res.put("totalCitas", citas.size());
        res.put("pendientes", pendientes);
        res.put("confirmadas", confirmadas);
        res.put("completadas", completadas);
        res.put("citas", citasEnriquecidas);
        return ResponseEntity.ok(res);
    }

    @PostMapping("/citas/{id}/estado")
    public ResponseEntity<?> cambiarEstadoCita(@PathVariable String id, @RequestBody Map<String, String> payload) {
        String estado = payload.get("estado");
        if (estado == null || estado.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "estado requerido"));
        }
        return citaRepository.findById(id).map(c -> {
            c.setEstado(estado);
            citaRepository.save(c);
            return ResponseEntity.ok(Map.of("success", true, "estado", c.getEstado()));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/citas/{id}/atender")
    public ResponseEntity<?> atenderCita(@PathVariable String id, @RequestBody Map<String, Object> payload) {
        return citaRepository.findById(id).map(cita -> {
            Visita v = visitaRepository.findByCitaId(cita.getId()).orElse(new Visita());
            v.setCitaId(cita.getId());
            v.setMascotaId(cita.getMascotaId());
            v.setClinicaId(cita.getClinicaId());
            v.setFechaVisita(LocalDateTime.now());
            if (payload.get("diagnostico") != null) v.setDiagnostico(payload.get("diagnostico").toString());
            if (payload.get("tratamiento") != null) v.setTratamiento(payload.get("tratamiento").toString());
            if (payload.get("notas") != null) v.setNotasAdicionales(payload.get("notas").toString());
            if (payload.get("medicamentos") != null) {
                String meds = payload.get("medicamentos").toString();
                if (!meds.isBlank()) {
                    v.setMedicamentosRecetados(Arrays.stream(meds.split(",")).map(String::trim).filter(s -> !s.isEmpty()).collect(Collectors.toList()));
                }
            }
            if (payload.get("peso") != null && !payload.get("peso").toString().isBlank()) {
                try { v.setPeso(Double.parseDouble(payload.get("peso").toString())); } catch (Exception ignored) {}
            }
            if (payload.get("temperatura") != null && !payload.get("temperatura").toString().isBlank()) {
                try { v.setTemperatura(Double.parseDouble(payload.get("temperatura").toString())); } catch (Exception ignored) {}
            }
            v.setCostoTotal(cita.getCosto() != null ? cita.getCosto() : 0.0);
            visitaRepository.save(v);

            cita.setEstado("COMPLETADA");
            citaRepository.save(cita);
            return ResponseEntity.ok(Map.of("success", true, "visitaId", v.getId()));
        }).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/inventario")
    public ResponseEntity<?> getInventario(@RequestParam String email) {
        Usuario user = usuarioRepository.findByEmail(email);
        String clinicaId = resolveClinicaId(user);
        List<Producto> all = productoService.findAll();
        if (clinicaId != null) {
            List<Producto> filtrados = all.stream()
                    .filter(p -> clinicaId.equals(p.getClinicaId()) || p.getClinicaId() == null || p.getClinicaId().isBlank())
                    .collect(Collectors.toList());
            return ResponseEntity.ok(filtrados);
        }
        return ResponseEntity.ok(all);
    }

    @PostMapping("/inventario")
    public ResponseEntity<?> saveProducto(@RequestBody Producto p, @RequestParam String email) {
        Usuario user = usuarioRepository.findByEmail(email);
        String clinicaId = resolveClinicaId(user);
        if (p.getClinicaId() == null || p.getClinicaId().isBlank()) {
            p.setClinicaId(clinicaId);
        }
        return ResponseEntity.ok(productoService.save(p));
    }

    @GetMapping("/servicios")
    public ResponseEntity<?> getServicios() {
        return ResponseEntity.ok(servicioService.findAll());
    }
}
