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
