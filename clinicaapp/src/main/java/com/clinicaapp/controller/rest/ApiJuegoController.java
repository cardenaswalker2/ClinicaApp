package com.clinicaapp.controller.rest;

import com.clinicaapp.model.MascotaVirtual;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IJuegoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/juego")
@CrossOrigin(origins = "*")
public class ApiJuegoController {

    @Autowired
    private IJuegoService juegoService;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @GetMapping("/estado")
    public ResponseEntity<?> getEstado(@RequestParam String email) {
        Usuario user = usuarioRepository.findByEmail(email);
        if (user == null) {
            return ResponseEntity.notFound().build();
        }
        MascotaVirtual mv = juegoService.obtenerMascotaUsuario(user.getId());
        return ResponseEntity.ok(mv);
    }

    @PostMapping("/accion")
    public ResponseEntity<?> realizarAccion(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");
        String accion = payload.get("accion");
        if (email == null || accion == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "email y accion requeridos"));
        }
        Usuario user = usuarioRepository.findByEmail(email);
        if (user == null) {
            return ResponseEntity.notFound().build();
        }
        MascotaVirtual mv = juegoService.realizarAccion(user.getId(), accion);
        return ResponseEntity.ok(mv);
    }
}
