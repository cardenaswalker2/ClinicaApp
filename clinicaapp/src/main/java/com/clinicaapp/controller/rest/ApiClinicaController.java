package com.clinicaapp.controller.rest;

import com.clinicaapp.model.Clinica;
import com.clinicaapp.model.enums.EstadoClinica;
import com.clinicaapp.repository.ClinicaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/clinicas")
@CrossOrigin(origins = "*")
public class ApiClinicaController {

    @Autowired
    private ClinicaRepository clinicaRepository;

    @Autowired
    private com.clinicaapp.repository.UsuarioRepository usuarioRepository;

    @GetMapping("/{id}/veterinarios")
    public ResponseEntity<List<java.util.Map<String, Object>>> getVeterinariosByClinica(@PathVariable String id) {
        List<com.clinicaapp.model.Usuario> vets = usuarioRepository.findByClinicaIdAndRole(
                id, com.clinicaapp.model.enums.Role.ROLE_VETERINARIO);
        if (vets.isEmpty()) {
            vets = usuarioRepository.findByRole(com.clinicaapp.model.enums.Role.ROLE_VETERINARIO);
        }
        List<java.util.Map<String, Object>> result = vets.stream()
                .filter(com.clinicaapp.model.Usuario::isActivo)
                .map(v -> {
                    java.util.Map<String, Object> m = new java.util.HashMap<>();
                    m.put("id", v.getId());
                    m.put("nombre", v.getNombre() + (v.getApellido() != null && !v.getApellido().isBlank() ? " " + v.getApellido() : ""));
                    m.put("especialidad", v.getEspecialidad() != null ? v.getEspecialidad() : "Medicina Veterinaria General");
                    return m;
                }).collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @GetMapping
    public ResponseEntity<List<Clinica>> getAllClinicas() {
        // Solo enviamos las clínicas que están APROBADAS
        List<Clinica> clinicas = clinicaRepository.findAll().stream()
                .filter(c -> c.getEstado() == EstadoClinica.APROBADA)
                .collect(Collectors.toList());
        return ResponseEntity.ok(clinicas);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Clinica> getClinicaById(@PathVariable String id) {
        return clinicaRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
