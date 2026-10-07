package com.clinicaapp.service.impl;

import com.clinicaapp.model.MensajeDirecto;
import com.clinicaapp.model.Notificacion;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.MensajeDirectoRepository;
import com.clinicaapp.repository.NotificacionRepository;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IEmailService;
import com.clinicaapp.service.IMensajeDirectoService;
import com.clinicaapp.service.LogActividadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class MensajeDirectoServiceImpl implements IMensajeDirectoService {

    @Autowired
    private MensajeDirectoRepository mensajeDirectoRepo;

    @Autowired
    private UsuarioRepository usuarioRepo;

    @Autowired
    private NotificacionRepository notificacionRepo;

    @Autowired
    private IEmailService emailService;

    @Autowired
    private LogActividadService logActividadService;

    @Override
    public MensajeDirecto enviarMensajeAdmin(String remitenteEmail, String remitenteNombre, 
                                            String destinatarioId, String asunto, String contenido) {
        Usuario destinatario = usuarioRepo.findById(destinatarioId).orElse(null);
        if (destinatario == null) {
            destinatario = usuarioRepo.findByEmail(destinatarioId);
        }

        if (destinatario == null) {
            throw new RuntimeException("El destinatario especificado no existe en el sistema.");
        }

        // Sanitización básica para prevenir XSS en frontend
        String asuntoSanitizado = asunto != null ? asunto.trim() : "Mensaje del Administrador";
        String contenidoSanitizado = contenido != null ? contenido.trim() : "";

        MensajeDirecto mensaje = new MensajeDirecto(
                remitenteEmail != null ? remitenteEmail : "superadmin@clinicaapp.com",
                remitenteNombre != null ? remitenteNombre : "Super Administrador",
                destinatario.getId(),
                destinatario.getEmail(),
                destinatario.getNombreCompleto(),
                asuntoSanitizado,
                contenidoSanitizado,
                "ADMIN_ALERT"
        );

        MensajeDirecto guardado = mensajeDirectoRepo.save(mensaje);

        // Crear una notificación interna en el drawer del usuario para que reciba la alerta inmediata
        try {
            Notificacion notif = new Notificacion(
                    destinatario.getId(),
                    "🔔 " + asuntoSanitizado,
                    contenidoSanitizado.length() > 100 ? contenidoSanitizado.substring(0, 97) + "..." : contenidoSanitizado,
                    "/usuario/mensajes"
            );
            notificacionRepo.save(notif);
        } catch (Exception e) {
            // Continuar
        }

        // Registrar auditoría de la acción administrativa
        try {
            logActividadService.registrarAuto(
                    "Mensaje directo enviado a usuario",
                    "MENSAJERIA",
                    "INFO",
                    "Super Admin envió mensaje interno a: " + destinatario.getEmail() + " (" + destinatario.getNombreCompleto() + ")"
            );
        } catch (Exception e) {
            // Continuar
        }

        return guardado;
    }

    @Override
    public List<MensajeDirecto> obtenerMensajesUsuario(String destinatarioEmail) {
        if (destinatarioEmail == null) return Collections.emptyList();
        return mensajeDirectoRepo.findByDestinatarioEmailOrderByFechaEnvioDesc(destinatarioEmail);
    }

    @Override
    public List<MensajeDirecto> obtenerMensajesNoLeidos(String destinatarioEmail) {
        if (destinatarioEmail == null) return Collections.emptyList();
        return mensajeDirectoRepo.findByDestinatarioEmailAndLeidoFalseOrderByFechaEnvioDesc(destinatarioEmail);
    }

    @Override
    public long contarNoLeidos(String destinatarioEmail) {
        if (destinatarioEmail == null) return 0;
        return mensajeDirectoRepo.countByDestinatarioEmailAndLeidoFalse(destinatarioEmail);
    }

    @Override
    public boolean marcarComoLeido(String mensajeId, String destinatarioEmail) {
        Optional<MensajeDirecto> opt = mensajeDirectoRepo.findById(mensajeId);
        if (opt.isPresent()) {
            MensajeDirecto msg = opt.get();
            // Validar que el mensaje pertenezca al usuario (o sea Super Admin)
            if (destinatarioEmail == null || msg.getDestinatarioEmail().equalsIgnoreCase(destinatarioEmail)) {
                msg.setLeido(true);
                msg.setFechaLectura(LocalDateTime.now());
                mensajeDirectoRepo.save(msg);
                return true;
            }
        }
        return false;
    }

    @Override
    public List<MensajeDirecto> obtenerHistorialEnviadosAdmin() {
        return mensajeDirectoRepo.findTop50ByOrderByFechaEnvioDesc();
    }

    @Override
    public List<MensajeDirecto> obtenerConversacionConUsuario(String usuarioIdOrEmail) {
        if (usuarioIdOrEmail.contains("@")) {
            return mensajeDirectoRepo.findByDestinatarioEmailOrderByFechaEnvioDesc(usuarioIdOrEmail);
        } else {
            return mensajeDirectoRepo.findByDestinatarioIdOrderByFechaEnvioDesc(usuarioIdOrEmail);
        }
    }

    @Override
    public Map<String, Object> enviarEmailDirecto(String destinatarioEmail, String asunto, String contenidoHtml) {
        Map<String, Object> respuesta = new HashMap<>();
        try {
            if (destinatarioEmail == null || destinatarioEmail.isBlank()) {
                throw new IllegalArgumentException("La dirección de correo destinataria no puede estar vacía.");
            }
            if (asunto == null || asunto.isBlank()) {
                throw new IllegalArgumentException("El asunto del correo no puede estar vacío.");
            }
            if (contenidoHtml == null || contenidoHtml.isBlank()) {
                throw new IllegalArgumentException("El cuerpo del correo no puede estar vacío.");
            }

            // Construcción del template HTML corporativo y responsive
            String plantillaHtml = 
                "<div style='font-family: \"Plus Jakarta Sans\", \"Segoe UI\", Helvetica, Arial, sans-serif; max-width: 620px; margin: 0 auto; background-color: #0b1120; color: #f8fafc; border-radius: 20px; overflow: hidden; border: 1px solid rgba(255,255,255,0.1); box-shadow: 0 20px 40px rgba(0,0,0,0.5);'>" +
                "  <div style='background: linear-gradient(135deg, #0ea5e9 0%, #6366f1 100%); padding: 35px 30px; text-align: center;'>" +
                "    <div style='width: 54px; height: 54px; background: rgba(255,255,255,0.2); border-radius: 14px; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center;'>" +
                "      <span style='color: white; font-size: 28px;'>🛡️</span>" +
                "    </div>" +
                "    <h1 style='margin: 0; font-size: 24px; font-weight: 800; color: #ffffff; letter-spacing: -0.5px;'>Comunicado de la Administración</h1>" +
                "    <p style='margin: 8px 0 0; color: rgba(255,255,255,0.85); font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px;'>Cl&iacute;nicaApp Core Platform</p>" +
                "  </div>" +
                "  <div style='padding: 35px 30px; background-color: #0f172a;'>" +
                "    <p style='font-size: 15px; color: #94a3b8; margin-top: 0;'>Estimado usuario,</p>" +
                "    <div style='margin: 25px 0; padding: 22px; background: rgba(255,255,255,0.03); border-radius: 16px; border: 1px solid rgba(255,255,255,0.08); color: #f1f5f9; font-size: 15px; line-height: 1.7;'>" +
                contenidoHtml.replace("\n", "<br>") +
                "    </div>" +
                "    <div style='padding: 16px 20px; background: rgba(14, 165, 233, 0.08); border-radius: 12px; border-left: 4px solid #0ea5e9; margin-top: 25px;'>" +
                "      <p style='margin: 0; font-size: 13px; color: #7dd3fc;'><b>Atentamente:</b> Equipo de Super Administración de Cl&iacute;nicaApp.</p>" +
                "    </div>" +
                "  </div>" +
                "  <div style='padding: 24px 30px; background: rgba(255,255,255,0.02); border-top: 1px solid rgba(255,255,255,0.06); text-align: center;'>" +
                "    <p style='margin: 0; font-size: 12px; color: #64748b;'>&copy; " + java.time.Year.now().getValue() + " Cl&iacute;nicaApp Pro. Todos los derechos reservados.<br>Este mensaje fue emitido directamente por un Super Administrador autorizado.</p>" +
                "  </div>" +
                "</div>";

            emailService.sendSimpleMessage(destinatarioEmail.trim(), asunto.trim(), plantillaHtml);

            logActividadService.registrarAuto(
                    "Correo electrónico enviado por Super Admin",
                    "MENSAJERIA",
                    "SUCCESS",
                    "Correo emitido exitosamente a: " + destinatarioEmail + " con asunto: '" + asunto + "'"
            );

            respuesta.put("success", true);
            respuesta.put("message", "El correo electrónico fue enviado exitosamente a " + destinatarioEmail);
            return respuesta;

        } catch (Exception e) {
            logActividadService.registrarAuto(
                    "Error al enviar correo por Super Admin",
                    "MENSAJERIA",
                    "ERROR",
                    "Fallo al enviar correo a " + destinatarioEmail + ": " + e.getMessage()
            );
            respuesta.put("success", false);
            respuesta.put("error", e.getMessage());
            return respuesta;
        }
    }
}
