package com.clinicaapp.controller.rest;

import com.clinicaapp.dto.PagoListDTO;
import com.clinicaapp.model.Cita;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.CitaRepository;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IClinicaService;
import com.clinicaapp.service.IMascotaService;
import com.clinicaapp.service.IServicioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/pagos")
@CrossOrigin(origins = "*")
public class ApiPagoController {

    @Autowired
    private CitaRepository citaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private IClinicaService clinicaService;

    @Autowired
    private IServicioService servicioService;

    @Autowired
    private IMascotaService mascotaService;

    @GetMapping("/usuario/{email}")
    public ResponseEntity<List<PagoListDTO>> getPagosByUser(@PathVariable String email) {
        Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario == null) {
            return ResponseEntity.notFound().build();
        }

        List<Cita> citasConPago = citaRepository.findByUsuarioId(usuario.getId()).stream()
                .filter(c -> c.getEstadoPago() != null && !c.getEstadoPago().isEmpty())
                .collect(Collectors.toList());

        List<PagoListDTO> pagos = citasConPago.stream().map(cita -> {
            PagoListDTO dto = new PagoListDTO();
            dto.setCitaId(cita.getId());
            dto.setFecha(cita.getFechaHora());
            dto.setMonto(cita.getCosto() != null ? cita.getCosto() : 0.0);
            dto.setPaymentIntentId(cita.getPaymentIntentId());

            if ("PAGADO".equalsIgnoreCase(cita.getEstadoPago())) {
                dto.setEstado("COMPLETADO");
            } else {
                dto.setEstado(cita.getEstadoPago());
            }

            clinicaService.findById(cita.getClinicaId())
                    .ifPresent(c -> {
                        dto.setNombreClinica(c.getNombre());
                        dto.setImagenClinicaUrl(c.getImagenUrl());
                    });

            List<String> nombresServicios = new ArrayList<>();
            if (cita.getServiciosIds() != null) {
                for (String sId : cita.getServiciosIds()) {
                    servicioService.findById(sId).ifPresent(s -> nombresServicios.add(s.getNombre()));
                }
            }
            dto.setNombreServicio(String.join(", ", nombresServicios));

            mascotaService.findById(cita.getMascotaId())
                    .ifPresent(m -> dto.setNombreMascota(m.getNombre()));

            return dto;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(pagos);
    }

    @GetMapping("/recibo/{citaId}")
    public ResponseEntity<?> getRecibo(@PathVariable String citaId) {
        return citaRepository.findById(citaId).map(cita -> {
            java.util.Map<String, Object> res = new java.util.HashMap<>();
            res.put("citaId", cita.getId());
            res.put("fecha", cita.getFechaHora() != null ? cita.getFechaHora().toString() : "");
            res.put("monto", cita.getCosto() != null ? cita.getCosto() : 0.0);
            res.put("estadoPago", cita.getEstadoPago() != null ? cita.getEstadoPago() : "PENDIENTE");
            res.put("paymentIntentId", cita.getPaymentIntentId() != null ? cita.getPaymentIntentId() : "N/A");
            res.put("motivo", cita.getMotivo() != null ? cita.getMotivo() : "Consulta Veterinaria");

            clinicaService.findById(cita.getClinicaId() != null ? cita.getClinicaId() : "")
                    .ifPresent(c -> {
                        res.put("clinicaNombre", c.getNombre());
                        res.put("clinicaDireccion", c.getDireccion());
                    });

            mascotaService.findById(cita.getMascotaId() != null ? cita.getMascotaId() : "")
                    .ifPresent(m -> res.put("mascotaNombre", m.getNombre()));

            if (cita.getUsuarioId() != null) {
                usuarioRepository.findById(cita.getUsuarioId())
                        .ifPresent(u -> res.put("usuarioNombre", u.getNombre() + (u.getApellido() != null ? " " + u.getApellido() : "")));
            }

            List<String> servicios = new ArrayList<>();
            if (cita.getServiciosIds() != null) {
                for (String sId : cita.getServiciosIds()) {
                    servicioService.findById(sId).ifPresent(s -> servicios.add(s.getNombre()));
                }
            }
            res.put("servicios", servicios);
            return ResponseEntity.ok(res);
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/pagar/{citaId}")
    public ResponseEntity<?> pagarCitaMobile(@PathVariable String citaId, @RequestBody(required = false) java.util.Map<String, Object> payload) {
        return citaRepository.findById(citaId).map(cita -> {
            cita.setEstadoPago("PAGADO");
            if (cita.getPaymentIntentId() == null || cita.getPaymentIntentId().isBlank()) {
                cita.setPaymentIntentId("PAY-MOB-" + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase());
            }
            citaRepository.save(cita);
            return ResponseEntity.ok(java.util.Map.of(
                    "success", true,
                    "estadoPago", "PAGADO",
                    "paymentIntentId", cita.getPaymentIntentId(),
                    "monto", cita.getCosto() != null ? cita.getCosto() : 0.0
            ));
        }).orElse(ResponseEntity.notFound().build());
    }
}
