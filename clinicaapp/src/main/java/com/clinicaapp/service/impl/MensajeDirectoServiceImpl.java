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
        mensaje.setOrigen("SUPER_ADMIN");
        mensaje.setEstadoMensaje("ENVIADO");
        mensaje.setConversacionUsuarioId(destinatario.getId());

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
    public MensajeDirecto responderMensajeUsuario(String usuarioEmail, String contenido, String asunto) {
        if (usuarioEmail == null || usuarioEmail.isBlank()) {
            throw new IllegalArgumentException("El correo del usuario no puede estar vacío.");
        }
        if (contenido == null || contenido.isBlank()) {
            throw new IllegalArgumentException("El mensaje de respuesta no puede estar vacío.");
        }

        Usuario usuario = usuarioRepo.findByEmail(usuarioEmail.trim());
        if (usuario == null) {
            usuario = usuarioRepo.findByEmail(usuarioEmail.toLowerCase().trim());
        }
        if (usuario == null) {
            throw new RuntimeException("Usuario no encontrado para registrar la respuesta.");
        }

        String asuntoSanitizado = (asunto != null && !asunto.isBlank()) ? asunto.trim() : "Respuesta de " + usuario.getNombreCompleto();
        String contenidoSanitizado = contenido.trim();

        MensajeDirecto respuesta = new MensajeDirecto();
        respuesta.setRemitenteEmail(usuario.getEmail());
        respuesta.setRemitenteNombre(usuario.getNombreCompleto());
        respuesta.setDestinatarioId("ADMIN_CORE");
        respuesta.setDestinatarioEmail("superadmin@clinicaapp.com");
        respuesta.setDestinatarioNombre("Super Administrador");
        respuesta.setAsunto(asuntoSanitizado);
        respuesta.setContenido(contenidoSanitizado);
        respuesta.setTipo("USER_REPLY");
        respuesta.setOrigen("USUARIO");
        respuesta.setEstadoMensaje("ENVIADO");
        respuesta.setConversacionUsuarioId(usuario.getId());
        respuesta.setFechaEnvio(LocalDateTime.now());
        respuesta.setLeido(false);

        MensajeDirecto guardado = mensajeDirectoRepo.save(respuesta);

        // Marcar mensajes anteriores enviados al usuario como leídos si responde
        try {
            List<MensajeDirecto> noLeidos = mensajeDirectoRepo.findByDestinatarioEmailAndLeidoFalseOrderByFechaEnvioDesc(usuario.getEmail());
            for (MensajeDirecto m : noLeidos) {
                m.setLeido(true);
                m.setFechaLectura(LocalDateTime.now());
                m.setEstadoMensaje("LEIDO");
                mensajeDirectoRepo.save(m);
            }
        } catch (Exception e) {
            // Continuar
        }

        return guardado;
    }

    @Override
    public List<MensajeDirecto> obtenerMensajesUsuario(String destinatarioEmailOrId) {
        if (destinatarioEmailOrId == null || destinatarioEmailOrId.isBlank()) return Collections.emptyList();
        String term = destinatarioEmailOrId.trim();

        // Buscar mensajes donde el destinatario sea el usuario O donde el remitente sea el usuario (hilo completo)
        Usuario u = null;
        if (term.contains("@")) {
            u = usuarioRepo.findByEmail(term);
            if (u == null) u = usuarioRepo.findByEmail(term.toLowerCase());
        } else {
            u = usuarioRepo.findById(term).orElse(null);
        }

        if (u != null) {
            List<MensajeDirecto> lista = mensajeDirectoRepo.findByConversacionUsuarioIdOrderByFechaEnvioAsc(u.getId());
            if (lista.isEmpty()) {
                lista = mensajeDirectoRepo.findByDestinatarioEmailOrderByFechaEnvioDesc(u.getEmail());
            }
            return lista;
        }

        return mensajeDirectoRepo.findByDestinatarioEmailOrderByFechaEnvioDesc(term);
    }

    @Override
    public List<MensajeDirecto> obtenerMensajesNoLeidos(String destinatarioEmailOrId) {
        if (destinatarioEmailOrId == null || destinatarioEmailOrId.isBlank()) return Collections.emptyList();
        List<MensajeDirecto> todos = obtenerMensajesUsuario(destinatarioEmailOrId);
        List<MensajeDirecto> noLeidos = new ArrayList<>();
        for (MensajeDirecto m : todos) {
            if (!m.isLeido() && "SUPER_ADMIN".equalsIgnoreCase(m.getOrigen())) noLeidos.add(m);
        }
        return noLeidos;
    }

    @Override
    public long contarNoLeidos(String destinatarioEmailOrId) {
        return obtenerMensajesNoLeidos(destinatarioEmailOrId).size();
    }

    @Override
    public boolean marcarComoLeido(String mensajeId, String destinatarioEmail) {
        Optional<MensajeDirecto> opt = mensajeDirectoRepo.findById(mensajeId);
        if (opt.isPresent()) {
            MensajeDirecto msg = opt.get();
            // Validar protección IDOR: debe ser el destinatario, remitente o admin
            if (destinatarioEmail != null && !destinatarioEmail.isBlank()) {
                boolean esDestinatario = msg.getDestinatarioEmail() != null && msg.getDestinatarioEmail().equalsIgnoreCase(destinatarioEmail.trim());
                boolean esRemitente = msg.getRemitenteEmail() != null && msg.getRemitenteEmail().equalsIgnoreCase(destinatarioEmail.trim());
                if (!esDestinatario && !esRemitente) {
                    return false;
                }
            }
            msg.setLeido(true);
            msg.setFechaLectura(LocalDateTime.now());
            msg.setEstadoMensaje("LEIDO");
            mensajeDirectoRepo.save(msg);
            return true;
        }
        return false;
    }

    @Override
    public List<MensajeDirecto> obtenerHistorialEnviadosAdmin() {
        return mensajeDirectoRepo.findTop50ByOrderByFechaEnvioDesc();
    }

    @Override
    public List<MensajeDirecto> obtenerConversacionConUsuario(String usuarioIdOrEmail) {
        if (usuarioIdOrEmail == null || usuarioIdOrEmail.isBlank()) return Collections.emptyList();
        
        Usuario usuario = null;
        if (usuarioIdOrEmail.contains("@")) {
            usuario = usuarioRepo.findByEmail(usuarioIdOrEmail.trim());
            if (usuario == null) usuario = usuarioRepo.findByEmail(usuarioIdOrEmail.toLowerCase().trim());
        } else {
            usuario = usuarioRepo.findById(usuarioIdOrEmail.trim()).orElse(null);
        }

        List<MensajeDirecto> conversacion = new ArrayList<>();
        if (usuario != null) {
            // 1. Buscar por conversacionUsuarioId
            conversacion = mensajeDirectoRepo.findByConversacionUsuarioIdOrderByFechaEnvioAsc(usuario.getId());

            // 2. Si no hay por ID de conversación, buscar por emails cruzados
            if (conversacion.isEmpty()) {
                conversacion = mensajeDirectoRepo.findByDestinatarioEmailOrRemitenteEmailOrderByFechaEnvioAsc(
                        usuario.getEmail(), usuario.getEmail()
                );
            }
        } else if (usuarioIdOrEmail.contains("@")) {
            conversacion = mensajeDirectoRepo.findByDestinatarioEmailOrRemitenteEmailOrderByFechaEnvioAsc(
                    usuarioIdOrEmail, usuarioIdOrEmail
            );
        }

        // Ordenar cronológicamente (antiguos arriba, nuevos abajo para estilo chat)
        conversacion.sort(Comparator.comparing(MensajeDirecto::getFechaEnvio, Comparator.nullsLast(Comparator.naturalOrder())));
        return conversacion;
    }

    @Override
    public Map<String, Object> enviarEmailDirecto(String destinatarioEmail, String asunto, String contenidoHtml) {
        return enviarEmailDirectoConAdjunto(destinatarioEmail, asunto, contenidoHtml, null, null);
    }

    @Override
    public Map<String, Object> enviarEmailDirectoConAdjunto(String destinatarioEmail, String asunto, String contenidoHtml, String nombreArchivo, byte[] archivoBytes) {
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

            // Construcción del template HTML corporativo, limpio y responsive
            String plantillaHtml = 
                "<div style='font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif; max-width: 620px; margin: 0 auto; background-color: #ffffff; color: #1e293b; border-radius: 16px; overflow: hidden; border: 1px solid #e2e8f0; box-shadow: 0 10px 30px rgba(0,0,0,0.08);'>" +
                "  <div style='background: linear-gradient(135deg, #0284c7 0%, #4f46e5 100%); padding: 32px 28px; text-align: center; color: #ffffff;'>" +
                "    <div style='width: 52px; height: 52px; background: rgba(255,255,255,0.2); border-radius: 14px; margin: 0 auto 14px; display: flex; align-items: center; justify-content: center; font-size: 26px;'>" +
                "      🛡️" +
                "    </div>" +
                "    <h1 style='margin: 0; font-size: 22px; font-weight: 800; color: #ffffff; letter-spacing: -0.5px;'>Comunicado Oficial de la Administración</h1>" +
                "    <p style='margin: 6px 0 0; color: rgba(255,255,255,0.9); font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 1.5px;'>Cl&iacute;nicaApp Core Platform</p>" +
                "  </div>" +
                "  <div style='padding: 32px 28px; background-color: #ffffff;'>" +
                "    <p style='font-size: 15px; color: #475569; margin-top: 0;'>Estimado usuario,</p>" +
                "    <div style='margin: 20px 0; padding: 20px; background: #f8fafc; border-radius: 12px; border: 1px solid #e2e8f0; color: #0f172a; font-size: 15px; line-height: 1.7;'>" +
                contenidoHtml.replace("\n", "<br>") +
                "    </div>" +
                (nombreArchivo != null && !nombreArchivo.isBlank() ? 
                    "<div style='margin: 16px 0; padding: 12px 16px; background: #f0fdf4; border-radius: 10px; border: 1px solid #bbf7d0; color: #166534; font-size: 13px; display: flex; align-items: center; gap: 8px;'>" +
                    "  <span>📎 <b>Documento adjunto:</b> " + nombreArchivo + "</span>" +
                    "</div>" : "") +
                "    <div style='padding: 14px 18px; background: #f0f9ff; border-radius: 10px; border-left: 4px solid #0284c7; margin-top: 24px;'>" +
                "      <p style='margin: 0; font-size: 13px; color: #0369a1;'><b>Atentamente:</b> Equipo de Super Administración de Cl&iacute;nicaApp.</p>" +
                "    </div>" +
                "  </div>" +
                "  <div style='padding: 20px 28px; background: #f8fafc; border-top: 1px solid #e2e8f0; text-align: center;'>" +
                "    <p style='margin: 0; font-size: 12px; color: #94a3b8;'>&copy; " + java.time.Year.now().getValue() + " Cl&iacute;nicaApp. Todos los derechos reservados.<br>Este mensaje fue emitido directamente por un Super Administrador autorizado.</p>" +
                "  </div>" +
                "</div>";

            if (archivoBytes != null && archivoBytes.length > 0 && nombreArchivo != null && !nombreArchivo.isBlank()) {
                emailService.sendMessageWithAttachment(destinatarioEmail.trim(), asunto.trim(), plantillaHtml, nombreArchivo, archivoBytes);
            } else {
                emailService.sendSimpleMessage(destinatarioEmail.trim(), asunto.trim(), plantillaHtml);
            }

            logActividadService.registrarAuto(
                    "Correo electrónico enviado por Super Admin",
                    "MENSAJERIA",
                    "SUCCESS",
                    "Correo emitido exitosamente a: " + destinatarioEmail + " con asunto: '" + asunto + "'" + (nombreArchivo != null ? " [Adjunto: " + nombreArchivo + "]" : "")
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
