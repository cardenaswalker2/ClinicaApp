package com.clinicaapp.controller.rest;

import com.clinicaapp.model.Recordatorio;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.RecordatorioRepository;
import com.clinicaapp.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/recordatorios")
@CrossOrigin(origins = "*") // Permite que la App móvil se conecte sin problemas de CORS
public class ApiRecordatorioController {

    @Autowired
    private RecordatorioRepository recordatorioRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @GetMapping("/usuario/{email}")
    public ResponseEntity<List<Recordatorio>> getRecordatoriosByUser(@PathVariable String email) {
        Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario == null) {
            return ResponseEntity.notFound().build();
        }
        List<Recordatorio> recordatorios = recordatorioRepository.findByUsuarioIdOrderByFechaHoraAsc(usuario.getId());
        return ResponseEntity.ok(recordatorios);
    }

    @PostMapping
    public ResponseEntity<Recordatorio> createRecordatorio(@RequestBody Recordatorio recordatorio) {
        // Aseguramos que el estado inicial sea PENDIENTE
        recordatorio.setEstado(Recordatorio.EstadoRecordatorio.PENDIENTE);
        Recordatorio nuevo = recordatorioRepository.save(recordatorio);
        return ResponseEntity.ok(nuevo);
    }
}
