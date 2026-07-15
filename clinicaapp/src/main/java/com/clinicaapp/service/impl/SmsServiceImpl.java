package com.clinicaapp.service.impl;

import com.clinicaapp.service.ISmsService;
import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

// --- IMPORT CORREGIDO ---
import jakarta.annotation.PostConstruct;
// ------------------------

@Service
public class SmsServiceImpl implements ISmsService {

    @Value("${twilio.account-sid}")
    private String accountSid;

    @Value("${twilio.auth-token}")
    private String authToken;

    @Value("${twilio.phone-number}")
    private String twilioPhoneNumber;

    @Autowired
    private com.clinicaapp.repository.LogNotificacionRepository logNotificacionRepo;

    @PostConstruct
    public void init() {
        // Este método se ejecuta automáticamente después de que se construye el bean
        // y se inyectan las dependencias. Es ideal para inicializar APIs como Twilio.
        Twilio.init(accountSid, authToken);
    }

    @Override
    public void sendSms(String toPhoneNumber, String messageBody) {
        try {
            Message message = Message.creator(
                    new PhoneNumber(toPhoneNumber),       // A
                    new PhoneNumber(twilioPhoneNumber),   // De
                    messageBody)
                    .create();
            System.out.println("SMS enviado con SID: " + message.getSid());
            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "SMS", toPhoneNumber, null, messageBody, "SUCCESS", "SMS enviado exitosamente. Twilio SID: " + message.getSid()
                ));
            } catch (Exception ex) {
                System.err.println("Fallo al guardar log de SMS: " + ex.getMessage());
            }
        } catch (Exception e) {
            System.err.println("Error al enviar SMS: " + e.getMessage());
            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "SMS", toPhoneNumber, null, messageBody, "FAILED", "Error: " + e.getMessage()
                ));
            } catch (Exception ex) {
                System.err.println("Fallo al guardar log de SMS fallido: " + ex.getMessage());
            }
            // No lanzamos excepción para evitar Whitelabel Error en el flujo del usuario
        }
    }

    @Override
    public void sendWhatsApp(String toPhoneNumber, String messageBody) {
        try {
            // Para WhatsApp con Twilio, el número debe empezar con "whatsapp:"
            String to = toPhoneNumber.startsWith("whatsapp:") ? toPhoneNumber : "whatsapp:" + toPhoneNumber;
            String from = twilioPhoneNumber.startsWith("whatsapp:") ? twilioPhoneNumber : "whatsapp:" + twilioPhoneNumber;

            Message message = Message.creator(
                    new PhoneNumber(to),
                    new PhoneNumber(from),
                    messageBody)
                    .create();
            System.out.println("WhatsApp enviado con SID: " + message.getSid());
            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "WHATSAPP", to, null, messageBody, "SUCCESS", "WhatsApp enviado exitosamente. Twilio SID: " + message.getSid()
                ));
            } catch (Exception ex) {
                System.err.println("Fallo al guardar log de WhatsApp: " + ex.getMessage());
            }
        } catch (Exception e) {
            System.err.println("Error al enviar WhatsApp: " + e.getMessage());
            try {
                logNotificacionRepo.save(new com.clinicaapp.model.LogNotificacion(
                    java.time.LocalDateTime.now(), "WHATSAPP", toPhoneNumber, null, messageBody, "FAILED", "Error: " + e.getMessage()
                ));
            } catch (Exception ex) {
                System.err.println("Fallo al guardar log de WhatsApp fallido: " + ex.getMessage());
            }
            // No lanzamos excepción para no romper el flujo principal si WhatsApp falla
        }
    }
}