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

    @Autowired
    private com.clinicaapp.service.IEmailService emailService;

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
            response.put("role", usuario.getRole() != null ? usuario.getRole().name() : "ROLE_USER");
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
            response.put("role", usuario.getRole() != null ? usuario.getRole().name() : "ROLE_USER");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error al procesar login de Google: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/perfil/{email}")
    public ResponseEntity<?> getPerfil(@PathVariable String email) {
        Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario == null) return ResponseEntity.notFound().build();
        Map<String, Object> res = new HashMap<>();
        res.put("id", usuario.getId());
        res.put("nombre", usuario.getNombre() != null ? usuario.getNombre() : "");
        res.put("apellido", usuario.getApellido() != null ? usuario.getApellido() : "");
        res.put("email", usuario.getEmail());
        res.put("telefono", usuario.getTelefono() != null ? usuario.getTelefono() : "");
        res.put("direccion", usuario.getDireccion() != null ? usuario.getDireccion() : "");
        res.put("latitud", usuario.getLatitud());
        res.put("longitud", usuario.getLongitud());
        return ResponseEntity.ok(res);
    }

    @PutMapping("/perfil/{email}")
    public ResponseEntity<?> updatePerfil(@PathVariable String email, @RequestBody Map<String, Object> payload) {
        Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario == null) return ResponseEntity.notFound().build();

        if (payload.get("nombre") != null) usuario.setNombre(payload.get("nombre").toString().trim());
        if (payload.get("apellido") != null) usuario.setApellido(payload.get("apellido").toString().trim());
        if (payload.get("telefono") != null) usuario.setTelefono(payload.get("telefono").toString().trim());
        if (payload.get("direccion") != null) usuario.setDireccion(payload.get("direccion").toString().trim());
        if (payload.get("latitud") != null && !payload.get("latitud").toString().isBlank()) {
            try { usuario.setLatitud(Double.parseDouble(payload.get("latitud").toString())); } catch (Exception ignored) {}
        }
        if (payload.get("longitud") != null && !payload.get("longitud").toString().isBlank()) {
            try { usuario.setLongitud(Double.parseDouble(payload.get("longitud").toString())); } catch (Exception ignored) {}
        }
        if (payload.get("password") != null && !payload.get("password").toString().isBlank()) {
            usuario.setPassword(passwordEncoder.encode(payload.get("password").toString()));
        }

        usuarioRepository.save(usuario);
        Map<String, Object> res = new HashMap<>();
        res.put("success", true);
        res.put("nombre", usuario.getNombre());
        res.put("apellido", usuario.getApellido());
        return ResponseEntity.ok(res);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");
        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "El correo es requerido"));
        }
        Usuario user = usuarioRepository.findByEmail(email.trim());
        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("success", false, "message", "No existe ninguna cuenta con ese correo"));
        }
        String token = java.util.UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        usuarioService.createPasswordResetTokenForUser(user, token);

        String subject = "Código de Recuperación - ClinicaApp";
        String body = "<div style='font-family: -apple-system, BlinkMacSystemFont, sans-serif; max-width: 520px; margin: 0 auto; padding: 28px; border: 1px solid #E5E5EA; border-radius: 16px;'>"
                + "<h2 style='color: #1C1C1E; margin-top: 0;'>Recuperar Contraseña</h2>"
                + "<p style='color: #3A3A3C;'>Hola <strong>" + user.getNombre() + "</strong>, usa este código en tu app móvil para restablecer tu contraseña:</p>"
                + "<div style='background: #F2F2F7; padding: 16px; border-radius: 12px; text-align: center; font-size: 28px; font-weight: 800; letter-spacing: 4px; color: #007AFF; margin: 20px 0;'>" + token + "</div>"
                + "<p style='color: #8E8E93; font-size: 13px;'>Si no solicitaste este código, puedes ignorar este mensaje.</p>"
                + "</div>";
        try {
            emailService.sendSimpleMessage(user.getEmail(), subject, body);
        } catch (Exception ignored) {}

        return ResponseEntity.ok(Map.of("success", true, "message", "Código enviado a tu correo electrónico"));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> payload) {
        String token = payload.get("token");
        String newPassword = payload.get("password");
        if (token == null || token.isBlank() || newPassword == null || newPassword.length() < 4) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Código y contraseña válida requeridos"));
        }
        Usuario user = usuarioService.validatePasswordResetToken(token.trim().toUpperCase());
        if (user == null) {
            user = usuarioService.validatePasswordResetToken(token.trim());
        }
        if (user == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("success", false, "message", "El código es inválido o ha expirado"));
        }
        usuarioService.changeUserPassword(user, newPassword);
        return ResponseEntity.ok(Map.of("success", true, "message", "Contraseña actualizada correctamente"));
    }
}
