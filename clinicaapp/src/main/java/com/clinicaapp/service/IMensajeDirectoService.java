package com.clinicaapp.service;

import com.clinicaapp.model.MensajeDirecto;
import org.springframework.data.domain.Page;

import java.util.List;
import java.util.Map;

public interface IMensajeDirectoService {

    // Enviar mensaje directo de Super Admin a un usuario específico
    MensajeDirecto enviarMensajeAdmin(String remitenteEmail, String remitenteNombre, 
                                     String destinatarioId, String asunto, String contenido);

    // Obtener bandeja de entrada de un usuario específico
    List<MensajeDirecto> obtenerMensajesUsuario(String destinatarioEmail);

    // Obtener mensajes no leídos
    List<MensajeDirecto> obtenerMensajesNoLeidos(String destinatarioEmail);

    // Contar no leídos
    long contarNoLeidos(String destinatarioEmail);

    // Marcar como leído
    boolean marcarComoLeido(String mensajeId, String destinatarioEmail);

    // Obtener historial de mensajes enviados por Super Admin
    List<MensajeDirecto> obtenerHistorialEnviadosAdmin();

    // Obtener historial de comunicación entre Super Admin y un usuario específico
    List<MensajeDirecto> obtenerConversacionConUsuario(String usuarioIdOrEmail);

    // Enviar correo electrónico real a través del proveedor de email configurado (Brevo/SMTP)
    Map<String, Object> enviarEmailDirecto(String destinatarioEmail, String asunto, String contenidoHtml);

    // Enviar correo electrónico con archivo adjunto
    Map<String, Object> enviarEmailDirectoConAdjunto(String destinatarioEmail, String asunto, String contenidoHtml, String nombreArchivo, byte[] archivoBytes);
}
