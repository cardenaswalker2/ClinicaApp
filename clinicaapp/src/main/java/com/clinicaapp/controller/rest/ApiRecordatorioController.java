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

    @PutMapping("/{id}")
    public ResponseEntity<?> updateRecordatorio(@PathVariable String id, @RequestBody java.util.Map<String, Object> payload) {
        return recordatorioRepository.findById(id).map(r -> {
            if (payload.get("titulo") != null) r.setTitulo(payload.get("titulo").toString());
            if (payload.get("descripcion") != null) r.setDescripcion(payload.get("descripcion").toString());
            if (payload.get("tipo") != null) {
                try { r.setTipo(Recordatorio.TipoRecordatorio.valueOf(payload.get("tipo").toString().toUpperCase())); } catch (Exception ignored) {}
            }
            if (payload.get("estado") != null) {
                try { r.setEstado(Recordatorio.EstadoRecordatorio.valueOf(payload.get("estado").toString().toUpperCase())); } catch (Exception ignored) {}
            }
            if (payload.get("fechaHora") != null) {
                try { r.setFechaHora(java.time.LocalDateTime.parse(payload.get("fechaHora").toString())); } catch (Exception ignored) {}
            }
            return ResponseEntity.ok(recordatorioRepository.save(r));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteRecordatorio(@PathVariable String id) {
        return recordatorioRepository.findById(id).map(r -> {
            recordatorioRepository.delete(r);
            return ResponseEntity.ok(java.util.Map.of("success", true));
        }).orElse(ResponseEntity.notFound().build());
    }
}
