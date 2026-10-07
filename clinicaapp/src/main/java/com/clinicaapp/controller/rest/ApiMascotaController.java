package com.clinicaapp.controller.rest;

import com.clinicaapp.model.Mascota;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.MascotaRepository;
import com.clinicaapp.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/mascotas")
@CrossOrigin(origins = "*")
public class ApiMascotaController {

    @Autowired
    private MascotaRepository mascotaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @GetMapping("/usuario/{email}")
    public ResponseEntity<List<Mascota>> getMascotasByUser(@PathVariable String email) {
        Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario == null) {
            return ResponseEntity.notFound().build();
        }
        List<Mascota> mascotas = mascotaRepository.findByPropietarioId(usuario.getId());
        return ResponseEntity.ok(mascotas);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Mascota> getMascota(@PathVariable String id) {
        return mascotaRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/album")
    public ResponseEntity<Mascota> addPhotoToAlbum(@PathVariable String id, @RequestBody String photoUrl) {
        // Limpiar comillas si vienen del body como string simple
        String cleanUrl = photoUrl.replace("\"", "");
        return mascotaRepository.findById(id).map(m -> {
            m.getAlbumFotos().add(cleanUrl);
            return ResponseEntity.ok(mascotaRepository.save(m));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/album/eliminar")
    public ResponseEntity<Mascota> removePhotoFromAlbum(@PathVariable String id, @RequestBody String photoUrl) {
        return mascotaRepository.findById(id).map(m -> {
            String target = photoUrl.replace("\"", "").trim();
            m.getAlbumFotos().removeIf(url -> url.replace("\"", "").trim().equals(target));
            return ResponseEntity.ok(mascotaRepository.save(m));
        }).orElse(ResponseEntity.notFound().build());
    }
    @PostMapping
    public ResponseEntity<?> createMascota(@RequestBody Mascota mascota) {
        if (mascota.getNombre() == null || mascota.getNombre().isBlank()) {
            return ResponseEntity.badRequest().body("El nombre de la mascota es requerido");
        }
        Mascota saved = mascotaRepository.save(mascota);
        return ResponseEntity.ok(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateMascota(@PathVariable String id, @RequestBody Mascota mascota) {
        return mascotaRepository.findById(id).map(existing -> {
            if (mascota.getNombre() != null) existing.setNombre(mascota.getNombre());
            if (mascota.getEspecie() != null) existing.setEspecie(mascota.getEspecie());
            if (mascota.getRazaPerro() != null) existing.setRazaPerro(mascota.getRazaPerro());
            if (mascota.getRazaGato() != null) existing.setRazaGato(mascota.getRazaGato());
            if (mascota.getRazaPersonalizada() != null) existing.setRazaPersonalizada(mascota.getRazaPersonalizada());
            if (mascota.getSexo() != null) existing.setSexo(mascota.getSexo());
            if (mascota.getFechaNacimiento() != null) existing.setFechaNacimiento(mascota.getFechaNacimiento());
            if (mascota.getFotoUrl() != null) existing.setFotoUrl(mascota.getFotoUrl());
            return ResponseEntity.ok(mascotaRepository.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMascota(@PathVariable String id) {
        return mascotaRepository.findById(id).map(m -> {
            mascotaRepository.delete(m);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }

    @Autowired
    private com.clinicaapp.service.IVisitaService visitaService;

    @Autowired
    private com.clinicaapp.service.IClinicaService clinicaService;

    @GetMapping("/{id}/historial")
    public ResponseEntity<?> getHistorialMascota(@PathVariable String id) {
        return mascotaRepository.findById(id).map(m -> {
            List<com.clinicaapp.model.Visita> visitas = visitaService.findByMascotaId(m.getId());
            List<java.util.Map<String, Object>> visitasEnriquecidas = visitas.stream().map(v -> {
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("id", v.getId());
                map.put("fechaVisita", v.getFechaVisita());
                map.put("diagnostico", v.getDiagnostico());
                map.put("tratamiento", v.getTratamiento());
                map.put("medicamentosRecetados", v.getMedicamentosRecetados());
                map.put("costoTotal", v.getCostoTotal());
                map.put("notasAdicionales", v.getNotasAdicionales());
                map.put("peso", v.getPeso());
                map.put("temperatura", v.getTemperatura());
                map.put("frecuenciaCardiaca", v.getFrecuenciaCardiaca());
                map.put("frecuenciaRespiratoria", v.getFrecuenciaRespiratoria());
                map.put("estadoConciencia", v.getEstadoConciencia());
                map.put("condicionCorporal", v.getCondicionCorporal());
                map.put("clinicaNombre", clinicaService.findById(v.getClinicaId()).map(com.clinicaapp.model.Clinica::getNombre).orElse("Clínica Veterinaria"));
                return map;
            }).collect(java.util.stream.Collectors.toList());
            return ResponseEntity.ok(visitasEnriquecidas);
        }).orElse(ResponseEntity.notFound().build());
    }
}
