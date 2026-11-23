package com.clinicaapp.controller.rest;

import com.clinicaapp.model.PublicacionAdopcion;
import com.clinicaapp.model.Resena;
import com.clinicaapp.model.enums.EstadoPublicacion;
import com.clinicaapp.repository.PublicacionAdopcionRepository;
import com.clinicaapp.repository.ResenaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ApiComunidadController {

    @Autowired
    private PublicacionAdopcionRepository adopcionRepository;

    @Autowired
    private ResenaRepository resenaRepository;

    @Autowired
    private com.clinicaapp.repository.MensajeChatRepository mensajeChatRepository;

    @Autowired
    private com.clinicaapp.repository.UsuarioRepository usuarioRepository;

    @GetMapping("/comunidad")
    public ResponseEntity<List<PublicacionAdopcion>> listarComunidad() {
        List<PublicacionAdopcion> aprobadas = adopcionRepository.findByEstado(EstadoPublicacion.DISPONIBLE);
        if (aprobadas.isEmpty()) {
            return ResponseEntity.ok(adopcionRepository.findAll());
        }
        return ResponseEntity.ok(aprobadas);
    }

    @PostMapping("/comunidad")
    public ResponseEntity<PublicacionAdopcion> crearPublicacion(@RequestBody Map<String, Object> payload) {
        PublicacionAdopcion pub = new PublicacionAdopcion();
        pub.setNombre(payload.getOrDefault("nombre", "Mascota en adopción").toString());
        pub.setEspecie(payload.getOrDefault("especie", "Perro").toString());
        pub.setRaza(payload.getOrDefault("raza", "Mestizo").toString());
        pub.setHistoria(payload.getOrDefault("historia", "").toString());
        pub.setCiudad(payload.getOrDefault("ciudad", "Cartagena").toString());
        pub.setNombrePublicador(payload.getOrDefault("nombrePublicador", "Usuario").toString());
        pub.setPropietarioId(payload.getOrDefault("propietarioId", "").toString());
        if (payload.get("fotoUrl") != null) {
            pub.setFotoPrincipalUrl(payload.get("fotoUrl").toString());
        }
        pub.setTipoPublicador("USER");
        pub.setEstado(EstadoPublicacion.DISPONIBLE);
        pub.setFechaCreacion(LocalDateTime.now());
        pub.setUltimaActualizacion(LocalDateTime.now());
        return ResponseEntity.ok(adopcionRepository.save(pub));
    }

    @PutMapping("/comunidad/{id}")
    public ResponseEntity<?> editarPublicacion(@PathVariable String id, @RequestBody Map<String, Object> payload) {
        return adopcionRepository.findById(id).map(pub -> {
            if (payload.get("nombre") != null) pub.setNombre(payload.get("nombre").toString());
            if (payload.get("especie") != null) pub.setEspecie(payload.get("especie").toString());
            if (payload.get("historia") != null) pub.setHistoria(payload.get("historia").toString());
            if (payload.get("fotoUrl") != null) pub.setFotoPrincipalUrl(payload.get("fotoUrl").toString());
            if (payload.get("estado") != null) {
                try { pub.setEstado(EstadoPublicacion.valueOf(payload.get("estado").toString().toUpperCase())); } catch (Exception ignored) {}
            }
            pub.setUltimaActualizacion(LocalDateTime.now());
            return ResponseEntity.ok(adopcionRepository.save(pub));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/comunidad/{id}")
    public ResponseEntity<?> eliminarPublicacion(@PathVariable String id) {
        return adopcionRepository.findById(id).map(pub -> {
            adopcionRepository.delete(pub);
            return ResponseEntity.ok(Map.of("success", true));
        }).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/comunidad/chat/{adopcionId}/{otroUsuarioId}")
    public ResponseEntity<?> obtenerChat(@PathVariable String adopcionId, @PathVariable String otroUsuarioId, @RequestParam String userId) {
        List<com.clinicaapp.model.MensajeChat> enviados = mensajeChatRepository.findByAdopcionIdAndEmisorIdAndReceptorId(adopcionId, userId, otroUsuarioId);
        List<com.clinicaapp.model.MensajeChat> recibidos = mensajeChatRepository.findByAdopcionIdAndReceptorIdAndEmisorId(adopcionId, userId, otroUsuarioId);
        java.util.List<com.clinicaapp.model.MensajeChat> todos = new java.util.ArrayList<>();
        todos.addAll(enviados);
        todos.addAll(recibidos);
        todos.sort(java.util.Comparator.comparing(m -> m.getFechaHora() != null ? m.getFechaHora() : LocalDateTime.MIN));
        return ResponseEntity.ok(todos);
    }

    @PostMapping("/comunidad/chat/enviar")
    public ResponseEntity<?> enviarMensajeChat(@RequestBody Map<String, String> payload) {
        String adopcionId = payload.get("adopcionId");
        String emisorId = payload.get("emisorId");
        String receptorId = payload.get("receptorId");
        String contenido = payload.get("contenido");
        if (adopcionId == null || emisorId == null || receptorId == null || contenido == null || contenido.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Faltan datos del mensaje"));
        }
        com.clinicaapp.model.MensajeChat msg = new com.clinicaapp.model.MensajeChat();
        msg.setAdopcionId(adopcionId);
        msg.setEmisorId(emisorId);
        msg.setReceptorId(receptorId);
        msg.setContenido(contenido.trim());
        msg.setFechaHora(LocalDateTime.now());
        usuarioRepository.findById(emisorId).ifPresent(u -> msg.setEmisorNombre(u.getNombre()));
        usuarioRepository.findById(receptorId).ifPresent(u -> msg.setReceptorNombre(u.getNombre()));
        return ResponseEntity.ok(mensajeChatRepository.save(msg));
    }

    @GetMapping("/clinicas/{clinicaId}/resenas")
    public ResponseEntity<List<Resena>> listarResenasClinica(@PathVariable String clinicaId) {
        return ResponseEntity.ok(resenaRepository.findByClinicaId(clinicaId));
    }

    @PostMapping("/clinicas/{clinicaId}/resenas")
    public ResponseEntity<Resena> crearResenaClinica(@PathVariable String clinicaId, @RequestBody Map<String, Object> payload) {
        Resena r = new Resena();
        r.setClinicaId(clinicaId);
        r.setUsuarioId(payload.getOrDefault("usuarioId", "").toString());
        r.setTitulo(payload.getOrDefault("titulo", "Opinión").toString());
        r.setComentario(payload.getOrDefault("comentario", "").toString());
        int cal = 5;
        try { cal = Integer.parseInt(payload.getOrDefault("calificacion", "5").toString()); } catch (Exception ignored) {}
        r.setCalificacion(Math.max(1, Math.min(5, cal)));
        r.setFechaCreacion(LocalDateTime.now());
        return ResponseEntity.ok(resenaRepository.save(r));
    }
}
