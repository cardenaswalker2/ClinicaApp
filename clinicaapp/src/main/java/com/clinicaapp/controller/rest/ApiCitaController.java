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
        Cita savedCita = citaRepository.save(cita);
        return ResponseEntity.ok(savedCita);
    }
}
