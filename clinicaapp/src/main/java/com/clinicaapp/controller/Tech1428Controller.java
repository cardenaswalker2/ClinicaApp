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

    private final RestTemplate restTemplate = new RestTemplate();

    @PostMapping("/send-email")
    public ResponseEntity<?> sendEmail(@RequestBody Map<String, String> payload) {
        try {
            String to = payload.get("to");
            String body = payload.get("body");
            
            String customBody = 
                "<div style='font-family: \"Plus Jakarta Sans\", \"Segoe UI\", sans-serif; max-width: 600px; margin: 0 auto; background-color: #030712; color: #f8fafc; border-radius: 24px; overflow: hidden; border: 1px solid rgba(255,255,255,0.1); box-shadow: 0 20px 50px rgba(0,0,0,0.5);'>" +
                "  <div style='background: linear-gradient(135deg, #0ea5e9 0%, #6366f1 100%); padding: 40px 30px; text-align: center;'>" +
                "    <div style='width: 60px; height: 60px; background: rgba(255,255,255,0.2); border-radius: 15px; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center;'>" +
                "      <span style='color: white; font-size: 30px;'>🧪</span>" +
                "    </div>" +
                "    <h1 style='margin: 0; font-size: 26px; font-weight: 800; letter-spacing: -1px;'>Ecosistema Tech 1428</h1>" +
                "    <p style='margin: 10px 0 0; color: rgba(255,255,255,0.8); font-size: 14px; text-transform: uppercase; tracking-widest: 2px;'>Notificaci&oacute;n de Sistema Inteligente</p>" +
                "  </div>" +
                "  <div style='padding: 40px 30px;'>" +
                "    <p style='font-size: 16px; color: #94a3b8; line-height: 1.6;'>Hola,</p>" +
                "    <p style='font-size: 16px; color: #e2e8f0; line-height: 1.6;'>Has recibido una notificaci&oacute;n generada por el motor de automatizaci&oacute;n de <b>ClinicaApp Pro</b>. Este es el contenido procesado:</p>" +
                "    <div style='margin: 30px 0; padding: 25px; background: rgba(255,255,255,0.03); border-radius: 18px; border: 1px solid rgba(255,255,255,0.08);'>" +
                "      <p style='margin: 0; color: #38bdf8; font-family: \"Courier New\", monospace; font-size: 14px; margin-bottom: 10px;'>[CONTENIDO DEL EVENTO]</p>" +
                "      <p style='margin: 0; color: #f8fafc; font-size: 18px; font-weight: 500;'>" + body + "</p>" +
                "    </div>" +
                "    <div style='padding: 20px; background: rgba(14, 165, 233, 0.1); border-radius: 12px; border-left: 4px solid #0ea5e9;'>" +
                "      <p style='margin: 0; font-size: 13px; color: #7dd3fc;'><b>Nota T&eacute;cnica:</b> Esta notificaci&oacute;n fue enviada a trav&eacute;s del protocolo seguro 1428 en tiempo real (45ms latencia).</p>" +
                "    </div>" +
                "  </div>" +
                "  <div style='padding: 30px; background: rgba(255,255,255,0.02); border-top: 1px solid rgba(255,255,255,0.05); text-align: center;'>" +
                "    <p style='margin: 0; font-size: 12px; color: #475569;'>&copy; 2026 ClinicaApp Ecosystem | 1428 Tech Stack <br> Este es un correo de simulaci&oacute;n para demostraci&oacute;n comercial.</p>" +
                "  </div>" +
                "</div>";
            
            emailService.sendSimpleMessage(to, "Simulaci&oacute;n de Funcionamiento - ClinicaApp", customBody);
            
            return ResponseEntity.ok(Map.of("message", "Simulación enviada con éxito a " + to));
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
            body.put("model", "llama-3.1-8b-instant");
            
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
