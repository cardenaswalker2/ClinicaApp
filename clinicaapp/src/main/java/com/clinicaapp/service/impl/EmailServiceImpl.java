package com.clinicaapp.service.impl;

import com.clinicaapp.service.IEmailService;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.io.File;

@Service
public class EmailServiceImpl implements IEmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailServiceImpl.class);

    @Autowired
    private JavaMailSender emailSender;

    // Obtenemos el email 'from' desde application.properties para no tenerlo hardcodeado
    @Value("${spring.mail.username}")
    private String fromEmail;

    @Autowired
    private com.clinicaapp.repository.LogNotificacionRepository logNotificacionRepo;

    @Override
    public void sendSimpleMessage(String to, String subject, String text) {
        try {
            // Para enviar HTML, necesitamos usar MimeMessageHelper
            MimeMessage message = emailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, "UTF-8"); // "UTF-8" para soportar caracteres especiales

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(text, true); // El 'true' indica que el contenido es HTML

            emailSender.send(message);
            log.info("Email HTML enviado exitosamente a {}", to);

            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "EMAIL", to, subject, text, "SUCCESS", "Mensaje de correo HTML enviado con éxito."
                ));
            } catch (Exception ex) {
                log.error("Fallo al guardar log de notificacion: {}", ex.getMessage());
            }

        } catch (Exception e) {
            log.error("Error al enviar email simple/HTML a {}: {}", to, e.getMessage());
            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "EMAIL", to, subject, text, "FAILED", "Error: " + e.getMessage()
                ));
            } catch (Exception ex) {
                log.error("Fallo al guardar log de notificacion fallido: {}", ex.getMessage());
            }
            throw new RuntimeException("Error al enviar email: " + e.getMessage(), e);
        }
    }

    @Override
    public void sendMessageWithAttachment(String to, String subject, String text, String pathToAttachment) {
        try {
            MimeMessage message = emailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(text, true);

            File file = new File(pathToAttachment);
            if (!file.exists()) {
                throw new RuntimeException("El archivo a adjuntar no fue encontrado en la ruta: " + pathToAttachment);
            }
            helper.addAttachment(file.getName(), file);

            emailSender.send(message);
            log.info("Email con adjunto ({}) enviado exitosamente a {}", file.getName(), to);

            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "EMAIL", to, subject, text, "SUCCESS", "Mensaje de correo con archivo adjunto enviado con éxito. Archivo: " + file.getName()
                ));
            } catch (Exception ex) {
                log.error("Fallo al guardar log de notificacion adjunto: {}", ex.getMessage());
            }

        } catch (MessagingException e) {
            log.error("Error al enviar email con adjunto de archivo a {}: {}", to, e.getMessage());
            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "EMAIL", to, subject, text, "FAILED", "Error en adjunto: " + e.getMessage()
                ));
            } catch (Exception ex) {
                log.error("Fallo al guardar log de notificacion fallido adjunto: {}", ex.getMessage());
            }
            throw new RuntimeException("Error al enviar email con adjunto: " + e.getMessage(), e);
        }
    }

    // --- MÉTODO NUEVO Y MÁS IMPORTANTE (QUE FALTABA) ---
    @Override
    public void sendMessageWithAttachment(String to, String subject, String text, String attachmentName, byte[] attachmentBytes) {
        try {
            MimeMessage message = emailSender.createMimeMessage();
            // true = multipart message, "UTF-8" = encoding
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(text, true); // true = el texto del cuerpo es HTML

            // Añadimos el adjunto desde el array de bytes
            // ByteArrayResource es la clave para adjuntar datos desde la memoria
            helper.addAttachment(attachmentName, new ByteArrayResource(attachmentBytes));

            emailSender.send(message);
            log.info("Email con adjunto en memoria ({}) enviado exitosamente a {}", attachmentName, to);

            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "EMAIL", to, subject, text, "SUCCESS", "Mensaje de correo con adjunto en memoria enviado con éxito. Archivo: " + attachmentName
                ));
            } catch (Exception ex) {
                log.error("Fallo al guardar log de notificacion en memoria: {}", ex.getMessage());
            }

        } catch (MessagingException e) {
            log.error("Error al enviar email con adjunto en memoria a {}: {}", to, e.getMessage());
            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "EMAIL", to, subject, text, "FAILED", "Error en adjunto en memoria: " + e.getMessage()
                ));
            } catch (Exception ex) {
                log.error("Fallo al guardar log de notificacion fallido en memoria: {}", ex.getMessage());
            }
            throw new RuntimeException("Error al enviar email con adjunto en memoria: " + e.getMessage(), e);
        }
    }
}