package com.clinicaapp.controller.rest;

import com.clinicaapp.dto.OptimizacionClinicaResultadoDTO;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IOptimizacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/optimizacion")
@CrossOrigin(origins = "*")
public class ApiOptimizacionController {

    @Autowired
    private IOptimizacionService optimizacionService;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @GetMapping("/clinicas")
    public ResponseEntity<OptimizacionClinicaResultadoDTO> optimizarClinicas(
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "15.0") double radio,
            @RequestParam(required = false) String direccion,
            @RequestParam(required = false) String email) {

        String direccionFinal = direccion;
        if ((direccionFinal == null || direccionFinal.isBlank()) && email != null) {
            Usuario u = usuarioRepository.findByEmail(email);
            if (u != null && u.getDireccion() != null && !u.getDireccion().isBlank()) {
                direccionFinal = u.getDireccion();
            }
        }
        if (direccionFinal == null || direccionFinal.isBlank()) {
            direccionFinal = "Ubicación móvil actual";
        }

        OptimizacionClinicaResultadoDTO resultado = optimizacionService.resolverOptimizacion(lat, lng, radio, direccionFinal);
        return ResponseEntity.ok(resultado);
    }
}
