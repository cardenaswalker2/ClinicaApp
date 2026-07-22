package com.clinicaapp.service.impl;

import com.clinicaapp.service.IEmailService;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.util.Base64;

@Service
public class EmailServiceImpl implements IEmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailServiceImpl.class);

    @Autowired(required = false)
    private JavaMailSender emailSender;

    @Value("${spring.mail.username:}")
    private String fromEmail;

    // API Key de Brevo (se lee de las variables de entorno de Render)
    @Value("${BREVO_API_KEY:}")
    private String brevoApiKey;

    @Autowired
    private com.clinicaapp.repository.LogNotificacionRepository logNotificacionRepo;

    @Async
    @Override
    public void sendSimpleMessage(String to, String subject, String text) {
        if (brevoApiKey != null && !brevoApiKey.trim().isEmpty()) {
            sendViaBrevoApi(to, subject, text, null, null);
            return;
        }

        try {
            if (emailSender == null) {
                throw new RuntimeException("JavaMailSender no está configurado.");
            }
            MimeMessage message = emailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(text, true);

            emailSender.send(message);
            log.info("Email HTML (SMTP) enviado exitosamente a {}", to);

            saveLog(to, subject, text, "SUCCESS", "Mensaje de correo HTML (SMTP) enviado con éxito.");
        } catch (Exception e) {
            log.error("Error al enviar email SMTP a {}: {}", to, e.getMessage());
            saveLog(to, subject, text, "FAILED", "Error SMTP: " + e.getMessage());
            throw new RuntimeException("Error al enviar email: " + e.getMessage(), e);
        }
    }

    @Async
    @Override
    public void sendMessageWithAttachment(String to, String subject, String text, String pathToAttachment) {
        byte[] bytes = null;
        String name = "";
        try {
            File file = new File(pathToAttachment);
            if (file.exists()) {
                bytes = Files.readAllBytes(file.toPath());
                name = file.getName();
            }
        } catch (Exception e) {
            log.error("Error al leer archivo adjunto: {}", e.getMessage());
        }

        if (brevoApiKey != null && !brevoApiKey.trim().isEmpty()) {
            sendViaBrevoApi(to, subject, text, name, bytes);
            return;
        }

        try {
            if (emailSender == null) {
                throw new RuntimeException("JavaMailSender no está configurado.");
            }
            MimeMessage message = emailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(text, true);

            File file = new File(pathToAttachment);
            if (!file.exists()) {
                throw new RuntimeException("Archivo no encontrado: " + pathToAttachment);
            }
            helper.addAttachment(file.getName(), file);

            emailSender.send(message);
            log.info("Email con adjunto (SMTP) enviado a {}", to);

            saveLog(to, subject, text, "SUCCESS", "Mensaje (SMTP) con adjunto enviado con éxito. Archivo: " + file.getName());
        } catch (Exception e) {
            log.error("Error al enviar email SMTP con adjunto a {}: {}", to, e.getMessage());
            saveLog(to, subject, text, "FAILED", "Error SMTP adjunto: " + e.getMessage());
            throw new RuntimeException("Error al enviar email con adjunto: " + e.getMessage(), e);
        }
    }

    @Async
    @Override
    public void sendMessageWithAttachment(String to, String subject, String text, String attachmentName, byte[] attachmentBytes) {
        if (brevoApiKey != null && !brevoApiKey.trim().isEmpty()) {
            sendViaBrevoApi(to, subject, text, attachmentName, attachmentBytes);
            return;
        }

        try {
            if (emailSender == null) {
                throw new RuntimeException("JavaMailSender no está configurado.");
            }
            MimeMessage message = emailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(text, true);
            helper.addAttachment(attachmentName, new ByteArrayResource(attachmentBytes));

            emailSender.send(message);
            log.info("Email con adjunto en memoria (SMTP) enviado a {}", to);

            saveLog(to, subject, text, "SUCCESS", "Mensaje (SMTP) con adjunto en memoria enviado con éxito. Archivo: " + attachmentName);
        } catch (Exception e) {
            log.error("Error al enviar email SMTP con adjunto en memoria a {}: {}", to, e.getMessage());
            saveLog(to, subject, text, "FAILED", "Error SMTP memoria: " + e.getMessage());
            throw new RuntimeException("Error al enviar email con adjunto: " + e.getMessage(), e);
        }
    }

    // --- ENVÍO A TRAVÉS DE HTTPS API (BREVO) ---
    private void sendViaBrevoApi(String to, String subject, String text, String attachmentName, byte[] attachmentBytes) {
        try {
            URL url = new URL("https://api.brevo.com/v3/smtp/email");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Accept", "application/json");
            conn.setRequestProperty("api-key", brevoApiKey.trim());
            conn.setDoOutput(true);

            // Escapar valores JSON básicos
            String escapedSubject = escapeJson(subject);
            String escapedText = escapeJson(text);
            String senderEmail = (fromEmail != null && !fromEmail.isEmpty()) ? fromEmail : "no-reply@clinicaapp.com";

            StringBuilder jsonBuilder = new StringBuilder();
            jsonBuilder.append("{");
            jsonBuilder.append("\"sender\":{\"name\":\"ClínicaApp\",\"email\":\"").append(senderEmail).append("\"},");
            jsonBuilder.append("\"to\":[{\"email\":\"").append(to).append("\"}],");
            jsonBuilder.append("\"subject\":\"").append(escapedSubject).append("\",");
            jsonBuilder.append("\"htmlContent\":\"").append(escapedText).append("\"");

            if (attachmentName != null && attachmentBytes != null) {
                String base64Content = Base64.getEncoder().encodeToString(attachmentBytes);
                jsonBuilder.append(",\"attachment\":[");
                jsonBuilder.append("{");
                jsonBuilder.append("\"name\":\"").append(escapeJson(attachmentName)).append("\",");
                jsonBuilder.append("\"content\":\"").append(base64Content).append("\"");
                jsonBuilder.append("}");
                jsonBuilder.append("]");
            }
            jsonBuilder.append("}");

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonBuilder.toString().getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int code = conn.getResponseCode();
            if (code >= 200 && code < 300) {
                log.info("Email API (Brevo) enviado exitosamente a {}", to);
                saveLog(to, subject, text, "SUCCESS", "Mensaje enviado a través de la API HTTPS de Brevo.");
            } else {
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), "utf-8"));
                StringBuilder response = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    response.append(responseLine.trim());
                }
                String errMessage = response.toString();
                log.error("Error API Brevo (Código {}): {}", code, errMessage);
                saveLog(to, subject, text, "FAILED", "Error API Brevo (" + code + "): " + errMessage);
                throw new RuntimeException("Error API Brevo: " + errMessage);
            }
        } catch (Exception e) {
            log.error("Error de conexión al enviar vía API Brevo a {}: {}", to, e.getMessage());
            saveLog(to, subject, text, "FAILED", "Error de conexión API: " + e.getMessage());
            throw new RuntimeException("Error API: " + e.getMessage(), e);
        }
    }

    private void saveLog(String to, String subject, String text, String estado, String detalles) {
        try {
            logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                java.time.LocalDateTime.now(), "EMAIL", to, subject, text, estado, detalles
            ));
        } catch (Exception ex) {
            log.error("Fallo al guardar log de notificacion: {}", ex.getMessage());
        }
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}