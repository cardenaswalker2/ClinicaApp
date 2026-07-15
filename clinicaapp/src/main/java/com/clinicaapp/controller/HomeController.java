package com.clinicaapp.controller;

import com.clinicaapp.model.Clinica;
import com.clinicaapp.model.Servicio;
import com.clinicaapp.service.IClinicaService;
import com.clinicaapp.service.IServicioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import com.clinicaapp.service.IEmailService;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Controller
public class HomeController {

    @Autowired
    private IClinicaService clinicaService;
    @Autowired
    private IServicioService servicioService;
    @Autowired
    private com.clinicaapp.repository.ConfiguracionRepository configRepo;
    @Autowired
    private IEmailService emailService;

    @GetMapping({ "/", "/index" })
    public String index(Model model) {
        // Obtenemos todas las clínicas
        List<Clinica> todasLasClinicas = clinicaService.findAll();

        // Las mezclamos para mostrar diferentes clínicas destacadas cada vez
        // Tomamos las primeras 15 para la página de inicio
        List<Clinica> clinicasDestacadas = todasLasClinicas.stream().limit(15).collect(Collectors.toList());

        model.addAttribute("clinicasDestacadas", clinicasDestacadas);

        return "index";
    }

    @GetMapping("/buscar-clinicas")
    public String buscarClinicas(@RequestParam(value = "query", required = false) String query,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "9") int size,
            Model model) {
        try {
            Pageable paging = PageRequest.of(page, size);
            Page<Clinica> clinicasPage;

            if (query != null && !query.isEmpty()) {
                clinicasPage = clinicaService.search(query, paging);
                model.addAttribute("query", query);
            } else {
                clinicasPage = clinicaService.findAll(paging);
            }

            model.addAttribute("clinicasPage", clinicasPage);

            // Lógica de paginación inteligente
            int totalPages = clinicasPage.getTotalPages();
            if (totalPages > 0) {
                int start = Math.max(1, page - 2);
                int end = Math.min(page + 3, totalPages);
                if (page < 3) {
                    end = Math.min(5, totalPages);
                }
                if (page > totalPages - 3) {
                    start = Math.max(1, totalPages - 4);
                }
                List<Integer> pageNumbers = IntStream.rangeClosed(start, end).boxed().collect(Collectors.toList());
                model.addAttribute("pageNumbers", pageNumbers);
            }

        } catch (Exception e) {
            model.addAttribute("errorMessage", "Error al cargar las clínicas.");
        }

        return "buscar_clinicas";
    }

    @GetMapping("/detalle-clinica/{id}")
    public String detalleClinica(@PathVariable String id, Model model) {
        Optional<Clinica> clinicaOpt = clinicaService.findById(id);

        if (clinicaOpt.isPresent()) {
            Clinica clinica = clinicaOpt.get();
            model.addAttribute("clinica", clinica);

            if (clinica.getServiciosOfrecidos() != null && !clinica.getServiciosOfrecidos().isEmpty()) {
                List<Servicio> serviciosCompletos = servicioService.findByIds(clinica.getServiciosOfrecidos());
                model.addAttribute("servicios", serviciosCompletos);
            } else {
                model.addAttribute("servicios", List.of());
            }

            return "detalle_clinica";
        } else {
            return "redirect:/buscar-clinicas?error=notfound";
        }
    }

    // --- MÉTODO FALTANTE AÑADIDO ---
    @GetMapping("/oficina-virtual")
    public String oficinaVirtual() {
        // Este método simplemente se encarga de mostrar la página HTML.
        // Toda la lógica de qué mostrar a cada rol está en el propio archivo
        // oficina_virtual.html usando los atributos de seguridad de Thymeleaf.
        return "oficina_virtual";
    }
    // -----------------------------

    @GetMapping("/publico/demo")
    public String mostrarDemo(Model model) {
        // No pasamos un usuario real, pasamos datos "ficticios" para la demo
        return "demo-interactiva";
    }

    @GetMapping("/1428")
    public String pagina1428(Model model) {
        return "1428";
    }

    @GetMapping("/mantenimiento")
    public String mantenimiento(Model model) {
        com.clinicaapp.model.ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new com.clinicaapp.model.ConfiguracionGlobal());
        
        String telRaw = config.getTelefonoSoporte() != null ? config.getTelefonoSoporte() : "300 572 2844";
        String telClean = telRaw.replaceAll("[^0-9]", "");
        // Si no empieza con código de país, asegurar que empiece con 57 para Colombia
        if (telClean.length() == 10 && telClean.startsWith("3")) {
            telClean = "57" + telClean;
        }
        
        model.addAttribute("telefonoSoporte", telRaw);
        model.addAttribute("telefonoSoporteClean", telClean);
        return "mantenimiento";
    }

    @GetMapping("/quiz")
    public String quizPublico(Model model) {
        return "quiz";
    }

    @GetMapping("/documentacion")
    public String documentacionPublica() {
        return "documentacion";
    }

    @GetMapping("/app")
    public String appDownload() {
        return "app_download";
    }

    // --- QR JOKE ENDPOINTS ---
    private static final java.util.Set<String> scannedQrCodes = java.util.concurrent.ConcurrentHashMap.newKeySet();

    @GetMapping("/api/quiz/scan-qr/{id}")
    public String scanQrFromMobile(@PathVariable String id, Model model) {
        scannedQrCodes.add(id);
        return "chupeta_mobile";
    }

    @GetMapping("/api/quiz/check-qr/{id}")
    @ResponseBody
    public ResponseEntity<?> checkQrStatus(@PathVariable String id) {
        boolean scanned = scannedQrCodes.contains(id);
        return ResponseEntity.ok(Map.of("scanned", scanned));
    }
    // -------------------------

    @PostMapping("/api/quiz/enviar-correo")
    @ResponseBody
    public ResponseEntity<?> enviarResultadosQuiz(@RequestBody Map<String, Object> payload) {
        String email = (String) payload.get("email");
        String nombre = (String) payload.get("nombre");
        Integer score = (Integer) payload.get("score");
        String certCode = (String) payload.get("certCode");
        String couponCode = (String) payload.get("couponCode");
        List<Map<String, Object>> respuestas = (List<Map<String, Object>>) payload.get("respuestas");

        if (email == null || email.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "El correo es obligatorio"));
        }

        // Si no pasaron código de certificado, lo generamos en el backend
        if (certCode == null || certCode.trim().isEmpty()) {
            certCode = "CA-" + (1000 + (int)(Math.random() * 9000)) + "-" + (char)('A' + (int)(Math.random() * 26));
        }

        // Si no pasaron el código de cupón de descuento, lo generamos en el backend como fallback
        if (couponCode == null || couponCode.trim().isEmpty()) {
            if (score != null && score >= 3) {
                couponCode = "EXCELENCIA-15-" + java.util.UUID.randomUUID().toString().substring(0, 5).toUpperCase();
            } else {
                couponCode = "BIENESTAR-5-" + java.util.UUID.randomUUID().toString().substring(0, 5).toUpperCase();
            }
        }

        String fecha = java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        StringBuilder htmlText = new StringBuilder();

        if (score != null && score >= 3) {
            // DISEÑO PREMIM DE CERTIFICADO DE EXCELENCIA (ESTILO HUD / CLÍNICA MEDICA ALTA FIDELIDAD)
            htmlText.append("<div style=\"background-color: #0f172a; padding: 40px 20px; font-family: 'Plus Jakarta Sans', Arial, sans-serif; text-align: center;\">");
            htmlText.append("    <div style=\"max-width: 600px; margin: auto; background-color: #ffffff; border: 12px double #10b981; border-radius: 16px; padding: 40px 30px; box-shadow: 0 20px 40px rgba(0,0,0,0.3);\">");
            htmlText.append("        <div style=\"text-align: center; margin-bottom: 20px;\">");
            htmlText.append("            <span style=\"font-size: 50px;\">🏆</span>");
            htmlText.append("        </div>");
            htmlText.append("        <h2 style=\"font-family: Arial, sans-serif; color: #065f46; font-size: 24px; font-weight: 700; margin: 0 0 10px 0; letter-spacing: 1px; text-transform: uppercase;\">");
            htmlText.append("            CERTIFICADO DE EXCELENCIA");
            htmlText.append("        </h2>");
            htmlText.append("        <p style=\"font-size: 14px; color: #64748b; margin: 0 0 30px 0; text-transform: uppercase; letter-spacing: 2px;\">");
            htmlText.append("            Otorgado por ClínicaApp a:");
            htmlText.append("        </p>");
            htmlText.append("        <h1 style=\"font-family: Arial, sans-serif; font-size: 32px; font-weight: 700; color: #1e1b4b; margin: 0 0 10px 0; border-bottom: 2px dashed #10b981; padding-bottom: 10px; display: inline-block; text-transform: uppercase;\">");
            htmlText.append("            ").append(nombre != null && !nombre.isEmpty() ? nombre : "Invitado");
            htmlText.append("        </h1>");
            htmlText.append("        <p style=\"font-size: 15px; color: #334155; line-height: 1.6; max-width: 480px; margin: 25px auto;\">");
            htmlText.append("            Por aprobar satisfactoriamente el Quiz de Evaluación de ClínicaApp con una puntuación destacada de ");
            htmlText.append("            <strong style=\"color: #10b981; font-size: 18px;\">").append(score).append("/5 puntos</strong>, demostrando un conocimiento completo de nuestra plataforma y servicios médicos inteligentes.");
            htmlText.append("        </p>");

            // TICKET EXCLUSIVO DEL 15% DE DESCUENTO
            htmlText.append("        <div style=\"margin: 35px 0; border: 2px dashed #10b981; border-radius: 12px; background-color: #f0fdf4; padding: 25px; text-align: center; font-family: Arial, sans-serif;\">");
            htmlText.append("            <div style=\"font-size: 11px; font-weight: 700; color: #047857; letter-spacing: 2px; text-transform: uppercase; margin-bottom: 5px;\">RECOMPENSA DE EXCELENCIA ADQUIRIDA</div>");
            htmlText.append("            <h2 style=\"color: #065f46; font-size: 26px; font-weight: 800; margin: 5px 0;\">15% DE DESCUENTO</h2>");
            htmlText.append("            <p style=\"font-size: 13px; color: #047857; margin: 0 0 15px 0;\">Válido para tu próxima consulta médica o servicio general en ClínicaApp</p>");
            htmlText.append("            <div style=\"display: inline-block; background-color: #ffffff; border: 1px solid #a7f3d0; border-radius: 8px; padding: 10px 20px; font-family: monospace; font-size: 18px; font-weight: 700; color: #065f46; letter-spacing: 1px; margin-bottom: 15px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);\">");
            htmlText.append("                ").append(couponCode);
            htmlText.append("            </div>");
            htmlText.append("            <div style=\"margin: 10px auto; max-width: 200px; height: 35px; background: repeating-linear-gradient(90deg, #065f46, #065f46 2px, transparent 2px, transparent 6px, #065f46 6px, #065f46 8px, transparent 8px, transparent 10px); opacity: 0.85;\"></div>");
            htmlText.append("            <div style=\"font-size: 11px; color: #047857; margin-top: 5px;\">Presenta este código digital en recepción. Válido por 3 meses.</div>");
            htmlText.append("        </div>");

            htmlText.append("        <div style=\"border-top: 1px solid #e2e8f0; margin-top: 40px; padding-top: 25px; font-size: 12px; color: #64748b;\">");
            htmlText.append("            <table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">");
            htmlText.append("                <tr>");
            htmlText.append("                    <td align=\"left\" style=\"font-family: Arial, sans-serif; font-weight: 500;\">");
            htmlText.append("                        Fecha: <strong>").append(fecha).append("</strong>");
            htmlText.append("                    </td>");
            htmlText.append("                    <td align=\"right\" style=\"font-family: Arial, sans-serif; font-weight: 500;\">");
            htmlText.append("                        Código de Verificación: <strong style=\"font-family: monospace; color: #0f172a;\">").append(certCode).append("</strong>");
            htmlText.append("                    </td>");
            htmlText.append("                </tr>");
            htmlText.append("            </table>");
            htmlText.append("        </div>");
            htmlText.append("    </div>");
            htmlText.append("</div>");
        } else {
            // DISEÑO PREMIUM DE RESULTADO DE EVALUACIÓN (CUANDO NO SE LOGRA EL PUNTAJE MÍNIMO)
            htmlText.append("<div style=\"background-color: #0f172a; padding: 40px 20px; font-family: 'Plus Jakarta Sans', Arial, sans-serif; text-align: center;\">");
            htmlText.append("    <div style=\"max-width: 600px; margin: auto; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; padding: 40px 30px; box-shadow: 0 20px 40px rgba(0,0,0,0.3); text-align: left;\">");
            htmlText.append("        <div style=\"text-align: center; margin-bottom: 25px;\">");
            htmlText.append("            <span style=\"font-size: 45px;\">📊</span>");
            htmlText.append("            <h2 style=\"color: #0ea5e9; font-weight: 700; margin: 10px 0 5px 0;\">Resultados de tu Evaluación</h2>");
            htmlText.append("            <p style=\"color: #64748b; margin: 0;\">ClínicaApp Quiz Interactivo</p>");
            htmlText.append("        </div>");
            htmlText.append("        <div style=\"background-color: #f8fafc; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 30px; border: 1px solid #e2e8f0;\">");
            htmlText.append("            <span style=\"font-size: 14px; color: #64748b; text-transform: uppercase; letter-spacing: 1px; display: block; margin-bottom: 5px;\">Puntaje Obtenido</span>");
            htmlText.append("            <strong style=\"font-size: 42px; color: #f43f5e;\">").append(score).append("/5</strong>");
            htmlText.append("            <p style=\"font-size: 14px; color: #475569; margin: 10px 0 0 0;\">¡Estuviste muy cerca! Sigue explorando nuestra plataforma ClínicaApp para obtener tu certificado de excelencia en tu próximo intento.</p>");
            htmlText.append("        </div>");

            // TICKET DE BIENESTAR DE CONSUELO (5% DE DESCUENTO)
            htmlText.append("        <div style=\"margin: 10px 0 30px 0; border: 2px dashed #6366f1; border-radius: 12px; background-color: #f5f3ff; padding: 25px; text-align: center; font-family: Arial, sans-serif;\">");
            htmlText.append("            <div style=\"font-size: 11px; font-weight: 700; color: #4f46e5; letter-spacing: 2px; text-transform: uppercase; margin-bottom: 5px;\">BONO DE BIENESTAR Y ESTÍMULO</div>");
            htmlText.append("            <h2 style=\"color: #4338ca; font-size: 26px; font-weight: 800; margin: 5px 0;\">5% DE DESCUENTO</h2>");
            htmlText.append("            <p style=\"font-size: 13px; color: #4f46e5; margin: 0 0 15px 0;\">¡Gracias por participar! Disfruta de este cupón de descuento en tu próxima visita médica.</p>");
            htmlText.append("            <div style=\"display: inline-block; background-color: #ffffff; border: 1px solid #ddd6fe; border-radius: 8px; padding: 10px 20px; font-family: monospace; font-size: 18px; font-weight: 700; color: #4338ca; letter-spacing: 1px; margin-bottom: 15px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);\">");
            htmlText.append("                ").append(couponCode);
            htmlText.append("            </div>");
            htmlText.append("            <div style=\"margin: 10px auto; max-width: 200px; height: 35px; background: repeating-linear-gradient(90deg, #4338ca, #4338ca 2px, transparent 2px, transparent 6px, #4338ca 6px, #4338ca 8px, transparent 8px, transparent 10px); opacity: 0.85;\"></div>");
            htmlText.append("            <div style=\"font-size: 11px; color: #4f46e5; margin-top: 5px;\">Presenta este código digital en recepción. Válido por 3 meses.</div>");
            htmlText.append("        </div>");
            
            htmlText.append("<h3 style=\"color: #0f172a; border-bottom: 2px solid #0ea5e9; padding-bottom: 5px; margin-top: 20px; font-size: 16px;\">Resumen del Intento:</h3>");
            htmlText.append("<ul style=\"list-style-type: none; padding-left: 0; margin: 0;\">");
            if (respuestas != null) {
                int idx = 1;
                for (Map<String, Object> resp : respuestas) {
                    String qText = (String) resp.get("qText");
                    Boolean correct = (Boolean) resp.get("correct");
                    String status = correct ? "<span style=\"color: #10b981; font-weight: bold;\">✔ Correcta</span>" : "<span style=\"color: #f43f5e; font-weight: bold;\">✘ Incorrecta</span>";
                    
                    htmlText.append("<li style=\"padding: 12px 0; border-bottom: 1px solid #f1f5f9;\">");
                    htmlText.append("    <strong style=\"color: #475569; display: block; margin-bottom: 3px;\">Pregunta ").append(idx++).append(":</strong> ").append(qText).append("<br/>");
                    htmlText.append("    Estado: ").append(status);
                    htmlText.append("</li>");
                }
            }
            htmlText.append("</ul>");
            
            htmlText.append("        <div style=\"text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8;\">");
            htmlText.append("            Este es un correo automático enviado por ClínicaApp. Visítanos en nuestra plataforma para más servicios.");
            htmlText.append("        </div>");
            htmlText.append("    </div>");
            htmlText.append("</div>");
        }

        try {
            emailService.sendSimpleMessage(email, "Resultados Oficiales - Quiz ClínicaApp", htmlText.toString());
            return ResponseEntity.ok(Map.of("success", true, "message", "Correo enviado correctamente"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("success", false, "message", "Error al enviar el correo: " + e.getMessage()));
        }
    }
}