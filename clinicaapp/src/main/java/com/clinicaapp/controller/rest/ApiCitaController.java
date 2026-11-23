package com.clinicaapp.controller.rest;

import com.clinicaapp.model.Cita;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.CitaRepository;
import com.clinicaapp.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/citas")
@CrossOrigin(origins = "*")
public class ApiCitaController {

    @Autowired
    private CitaRepository citaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private com.clinicaapp.repository.VisitaRepository visitaRepository;

    @Autowired
    private com.clinicaapp.repository.ClinicaRepository clinicaRepository;

    @Autowired
    private com.clinicaapp.repository.MascotaRepository mascotaRepository;

    @Autowired
    private com.clinicaapp.repository.ServicioRepository servicioRepository;

    @GetMapping("/usuario/{email}")
    public ResponseEntity<List<Cita>> getCitasByUser(@PathVariable String email) {
        Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario == null) {
            return ResponseEntity.notFound().build();
        }
        // Buscamos todas las citas del usuario
        List<Cita> citas = citaRepository.findByUsuarioId(usuario.getId());
        return ResponseEntity.ok(citas);
    }

    @PostMapping
    public ResponseEntity<Cita> createCita(@RequestBody Cita cita) {
        if (cita.getEstado() == null) {
            cita.setEstado("Pendiente");
        }
        if (cita.getEstadoPago() == null) {
            cita.setEstadoPago("PENDIENTE");
        }
        if ((cita.getCosto() == null || cita.getCosto() <= 0) && cita.getServiciosIds() != null && !cita.getServiciosIds().isEmpty()) {
            double total = 0.0;
            com.clinicaapp.model.Clinica clinica = cita.getClinicaId() != null
                    ? clinicaRepository.findById(cita.getClinicaId()).orElse(null)
                    : null;
            for (String sId : cita.getServiciosIds()) {
                double precio = 0.0;
                if (clinica != null && clinica.getPreciosServicios() != null && clinica.getPreciosServicios().containsKey(sId)) {
                    precio = clinica.getPreciosServicios().get(sId);
                } else {
                    precio = servicioRepository.findById(sId).map(s -> s.getCosto() != null ? s.getCosto() : 0.0).orElse(0.0);
                }
                total += precio;
            }
            if (total > 0) {
                cita.setCosto(total);
            }
        }
        Cita savedCita = citaRepository.save(cita);
        return ResponseEntity.ok(savedCita);
    }

    @GetMapping("/{id}/receta")
    public ResponseEntity<?> getRecetaCita(@PathVariable String id) {
        return citaRepository.findById(id).map(cita -> {
            java.util.Map<String, Object> res = new java.util.HashMap<>();
            res.put("citaId", cita.getId());
            res.put("fechaHora", cita.getFechaHora() != null ? cita.getFechaHora().toString() : "");
            res.put("motivo", cita.getMotivo() != null ? cita.getMotivo() : "");
            res.put("estado", cita.getEstado() != null ? cita.getEstado() : "");

            clinicaRepository.findById(cita.getClinicaId() != null ? cita.getClinicaId() : "")
                    .ifPresent(c -> {
                        res.put("clinicaNombre", c.getNombre());
                        res.put("clinicaDireccion", c.getDireccion());
                        res.put("clinicaTelefono", c.getTelefono());
                    });

            mascotaRepository.findById(cita.getMascotaId() != null ? cita.getMascotaId() : "")
                    .ifPresent(m -> {
                        res.put("mascotaNombre", m.getNombre());
                        res.put("mascotaEspecie", m.getEspecie());
                    });

            if (cita.getVeterinarioId() != null) {
                usuarioRepository.findById(cita.getVeterinarioId())
                        .ifPresent(v -> res.put("veterinarioNombre", v.getNombre() + " " + (v.getApellido() != null ? v.getApellido() : "")));
            }

            visitaRepository.findByCitaId(cita.getId()).ifPresent(v -> {
                res.put("tieneVisita", true);
                res.put("diagnostico", v.getDiagnostico() != null ? v.getDiagnostico() : "");
                res.put("tratamiento", v.getTratamiento() != null ? v.getTratamiento() : "");
                res.put("medicamentos", v.getMedicamentosRecetados() != null ? v.getMedicamentosRecetados() : java.util.List.of());
                res.put("notas", v.getNotasAdicionales() != null ? v.getNotasAdicionales() : "");
                res.put("peso", v.getPeso());
                res.put("temperatura", v.getTemperatura());
            });
            res.putIfAbsent("tieneVisita", false);
            return ResponseEntity.ok(res);
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/cancelar")
    public ResponseEntity<?> cancelarCita(@PathVariable String id) {
        return citaRepository.findById(id).map(cita -> {
            cita.setEstado("CANCELADA");
            return ResponseEntity.ok(citaRepository.save(cita));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/reprogramar")
    public ResponseEntity<?> reprogramarCita(@PathVariable String id, @RequestBody java.util.Map<String, String> payload) {
        String nuevaFechaHora = payload.get("fechaHora");
        if (nuevaFechaHora == null) return ResponseEntity.badRequest().body("fechaHora es requerida");
        return citaRepository.findById(id).map(cita -> {
            try {
                cita.setFechaHora(java.time.LocalDateTime.parse(nuevaFechaHora));
                cita.setEstado("Pendiente");
                return ResponseEntity.ok(citaRepository.save(cita));
            } catch (Exception e) {
                return ResponseEntity.badRequest().body("Formato de fecha inválido");
            }
        }).orElse(ResponseEntity.notFound().build());
    }
}
