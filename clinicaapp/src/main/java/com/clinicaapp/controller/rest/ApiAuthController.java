package com.clinicaapp.controller.rest;

import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class ApiAuthController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private com.clinicaapp.service.IUsuarioService usuarioService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        Usuario usuario = usuarioRepository.findByEmail(email);
        
        if (usuario != null && passwordEncoder.matches(password, usuario.getPassword())) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("email", usuario.getEmail());
            response.put("nombre", usuario.getNombre());
            response.put("id", usuario.getId());
            return ResponseEntity.ok(response);
        } else {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Credenciales incorrectas");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody com.clinicaapp.dto.UsuarioRegistroDTO registroDTO) {
        try {
            // Asignar rol de USUARIO por defecto para registros móviles
            if (registroDTO.getRole() == null) {
                registroDTO.setRole(com.clinicaapp.model.enums.Role.ROLE_USER);
            }
            usuarioService.save(registroDTO);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Usuario registrado exitosamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error al registrar: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }

    @PostMapping("/google")
    public ResponseEntity<?> googleLogin(@RequestBody Map<String, String> payload) {
        try {
            String email = payload.get("email");
            String nombre = payload.get("nombre");

            if (email == null || email.isBlank()) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "El email de Google es requerido");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            Usuario usuario = usuarioRepository.findByEmail(email);
            if (usuario == null) {
                // Registrar automáticamente al usuario si ingresa con Google por primera vez
                usuario = new Usuario();
                usuario.setEmail(email);
                // Dividir el nombre completo en nombre y apellido si es posible
                if (nombre != null && nombre.contains(" ")) {
                    int firstSpace = nombre.indexOf(" ");
                    usuario.setNombre(nombre.substring(0, firstSpace));
                    usuario.setApellido(nombre.substring(firstSpace + 1));
                } else {
                    usuario.setNombre(nombre != null ? nombre : "Usuario Google");
                    usuario.setApellido("");
                }
                usuario.setRole(com.clinicaapp.model.enums.Role.ROLE_USER);
                usuario.setActivo(true);
                usuario.setFechaCreacion(java.time.LocalDateTime.now());
                // Contraseña dummy encriptada aleatoria
                usuario.setPassword(passwordEncoder.encode(java.util.UUID.randomUUID().toString()));
                usuario = usuarioRepository.save(usuario);
            }

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("email", usuario.getEmail());
            response.put("nombre", usuario.getNombre());
            response.put("id", usuario.getId());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error al procesar login de Google: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
