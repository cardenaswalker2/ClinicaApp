package com.clinicaapp.controller;

import com.clinicaapp.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/1428")
public class Tech1428Controller {

    @Autowired
    private IEmailService emailService;

    @Autowired
    private ISmsService smsService;

    @Autowired
    private IPredictiveHealthService predictiveHealthService;

    @Autowired
    private IPdfService pdfService;

    @Autowired
    private IUsuarioService usuarioService;

    @Autowired
    private IClinicaService clinicaService;

    @Autowired
    private IStripeService stripeService;

    @Value("${groq.api.key:}")
    private String groqApiKey;

    @Value("${groq.api.url:https://api.groq.com/openai/v1/chat/completions}")
    private String groqApiUrl;

    @Value("${groq.api.model:llama-3.3-70b-versatile}")
    private String groqApiModel;

    private final RestTemplate restTemplate = new RestTemplate();

    @PostMapping("/send-email")
    public ResponseEntity<?> sendEmail(@RequestBody Map<String, String> payload) {
        try {
            String to = payload.get("to");
            String body = payload.getOrDefault("body", "");
            String subject = payload.getOrDefault("subject", "Notificación Oficial — ClinicaApp");
            if (subject.isBlank()) subject = "Notificación Oficial — ClinicaApp";
            String recipientName = payload.getOrDefault("recipientName", "Tutor");
            if (recipientName.isBlank()) recipientName = "Tutor";
            String category = payload.getOrDefault("category", "Comunicado");
            if (category.isBlank()) category = "Comunicado";

            String safeBody = body.replace("\n", "<br>");

            String customBody =
                "<div style='font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, sans-serif; background-color: #f2f2f7; padding: 32px 16px;'>" +
                "  <div style='max-width: 580px; margin: 0 auto; background-color: #ffffff; border-radius: 24px; overflow: hidden; border: 1px solid #e5e5ea; box-shadow: 0 12px 30px rgba(0,0,0,0.06);'>" +
                "    <div style='background: linear-gradient(135deg, #007aff 0%, #5856d6 100%); padding: 32px 28px; text-align: center;'>" +
                "      <div style='display: inline-block; padding: 10px 14px; background: rgba(255,255,255,0.18); border-radius: 14px; margin-bottom: 12px; font-size: 24px;'>🐾</div>" +
                "      <h1 style='margin: 0; color: #ffffff; font-size: 24px; font-weight: 800; letter-spacing: -0.5px;'>ClinicaApp</h1>" +
                "      <p style='margin: 6px 0 0; color: rgba(255,255,255,0.9); font-size: 13px; font-weight: 600;'>Plataforma Integral de Gestión Veterinaria</p>" +
                "    </div>" +
                "    <div style='padding: 30px 28px;'>" +
                "      <span style='display: inline-block; background-color: #e8f2ff; color: #007aff; font-size: 12px; font-weight: 700; padding: 5px 12px; border-radius: 20px; margin-bottom: 16px;'>" + category + "</span>" +
                "      <p style='margin: 0 0 12px; font-size: 17px; font-weight: 700; color: #1c1c1e;'>Hola, " + recipientName + ":</p>" +
                "      <div style='margin: 18px 0; padding: 20px; background-color: #f8f9fc; border-radius: 16px; border: 1px solid #e5e5ea; border-left: 4px solid #007aff;'>" +
                "        <p style='margin: 0; color: #1c1c1e; font-size: 15px; line-height: 1.6;'>" + safeBody + "</p>" +
                "      </div>" +
                "      <p style='margin: 20px 0 0; font-size: 13px; color: #6e6e73; line-height: 1.5;'>Si tienes dudas, puedes responder desde el asistente inteligente <b>Nova AI</b> dentro de la aplicación móvil o web de ClinicaApp.</p>" +
                "    </div>" +
                "    <div style='padding: 20px 28px; background-color: #f9f9fb; border-top: 1px solid #e5e5ea; text-align: center;'>" +
                "      <p style='margin: 0; font-size: 12px; color: #8e8e93;'>&copy; 2026 ClinicaApp • Cartagena de Indias, Colombia</p>" +
                "    </div>" +
                "  </div>" +
                "</div>";

            emailService.sendSimpleMessage(to, subject, customBody);

            return ResponseEntity.ok(Map.of("message", "Correo enviado exitosamente a " + to));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/analyze-ai")
    public ResponseEntity<?> analyzeAi(@RequestBody Map<String, String> payload) {
        try {
            String prompt = payload.get("prompt");
            
            // Validación de API Key
            if (groqApiKey == null || groqApiKey.isEmpty() || groqApiKey.startsWith("gsk_TU_API_KEY")) {
                return ResponseEntity.ok(Map.of("analysis", "An&aacute;lisis IA (Modo Demo): Los s&iacute;ntomas '" + prompt + "' sugieren un cuadro viral leve. Recomendamos hidrataci&oacute;n. (Conecte su API Key de Groq para an&aacute;lisis real)."));
            }

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(groqApiKey);

            Map<String, Object> body = new HashMap<>();
            body.put("model", groqApiModel);
            
            List<Map<String, String>> messages = new ArrayList<>();
            messages.add(Map.of("role", "system", "content", 
                "Eres el Analista de Salud IA del Ecosistema 1428 Tech. " +
                "Tu objetivo es dar diagnósticos preliminares profesionales y técnicos basados en síntomas veterinarios. " +
                "Responde con autoridad técnica, usa terminología médica veterinaria. " +
                "Sé conciso (máximo 3-4 oraciones). Finaliza siempre con una recomendación de cita profesional."));
            messages.add(Map.of("role", "user", "content", prompt));
            
            body.put("messages", messages);
            body.put("temperature", 0.5);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
            var response = restTemplate.postForObject(groqApiUrl, request, Map.class);
            
            String aiResult = "No se pudo procesar el análisis en este momento.";
            if (response != null && response.containsKey("choices")) {
                List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
                if (!choices.isEmpty()) {
                    Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                    aiResult = (String) message.get("content");
                }
            }

            return ResponseEntity.ok(Map.of("analysis", aiResult));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Fallo en motor IA: " + e.getMessage()));
        }
    }

    @PostMapping("/send-sms")
    public ResponseEntity<?> sendSms(@RequestBody Map<String, String> payload) {
        try {
            String to = payload.get("to");
            String message = payload.get("message");
            String type = payload.get("type"); // "sms" o "whatsapp"
            
            if ("whatsapp".equalsIgnoreCase(type)) {
                smsService.sendWhatsApp(to, message);
            } else {
                smsService.sendSms(to, message);
            }
            
            return ResponseEntity.ok(Map.of("message", "Mensaje enviado exitosamente a " + to));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/stats")
    public ResponseEntity<?> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", usuarioService.findAllUsers().size());
        stats.put("totalClinics", clinicaService.findAll().size());
        stats.put("uptime", "99.98%");
        stats.put("responseTime", "42ms");
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/generate-pdf")
    public ResponseEntity<byte[]> generatePdf() {
        try {
            Map<String, Object> data = new HashMap<>();
            data.put("title", "Reporte Tecnico 1428");
            data.put("content", "Este es un reporte generado automaticamente por ClinicaApp para demostrar el servicio de PDF.");
            
            // Usamos una de las plantillas existentes
            java.io.ByteArrayInputStream bis = pdfService.generatePdfFromTemplate("pdf/reporte_template", data);
            byte[] pdfBytes = bis.readAllBytes();
            
            return ResponseEntity.ok()
                    .header("Content-Type", "application/pdf")
                    .header("Content-Disposition", "attachment; filename=reporte-1428.pdf")
                    .body(pdfBytes);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/simulate-payment")
    public ResponseEntity<?> simulatePayment(@RequestBody Map<String, Object> payload) {
        try {
            // Creamos un intento de pago de $50 USD (5000 centavos)
            var intent = stripeService.createPaymentIntent(5000L, "usd", "Pago demostración Portal 1428");
            return ResponseEntity.ok(Map.of(
                "clientSecret", intent.getClientSecret(),
                "status", intent.getStatus(),
                "message", "Intento de pago creado exitosamente en Stripe"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
