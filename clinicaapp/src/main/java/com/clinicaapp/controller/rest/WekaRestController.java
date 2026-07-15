package com.clinicaapp.controller.rest;

import com.clinicaapp.service.WekaAdvancedHealthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/weka")
public class WekaRestController {

    @Autowired
    private WekaAdvancedHealthService wekaService;

    @PostMapping("/predict-health/{mascotaId}")
    public ResponseEntity<?> predecirSalud(@PathVariable String mascotaId, @RequestBody Map<String, String> respuestas) {
        try {
            Map<String, Object> resultado = wekaService.analizarSaludAvanzada(mascotaId, respuestas);
            return ResponseEntity.ok(resultado);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
