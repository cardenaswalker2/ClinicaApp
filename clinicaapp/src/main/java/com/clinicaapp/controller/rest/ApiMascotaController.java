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
}
