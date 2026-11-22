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
        pub.setTipoPublicador("USER");
        pub.setEstado(EstadoPublicacion.DISPONIBLE);
        pub.setFechaCreacion(LocalDateTime.now());
        pub.setUltimaActualizacion(LocalDateTime.now());
        return ResponseEntity.ok(adopcionRepository.save(pub));
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
