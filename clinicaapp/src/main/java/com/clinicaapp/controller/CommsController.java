package com.clinicaapp.controller;

import com.clinicaapp.model.*;
import com.clinicaapp.repository.*;
import com.clinicaapp.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/admin")
public class CommsController {

    @Autowired
    private LogNotificacionRepository logNotificacionRepo;

    @Autowired
    private IEmailService emailService;

    @Autowired
    private ISmsService smsService;

    @Autowired
    private ConfiguracionRepository configRepo;

    @Autowired
    private LogActividadService logActividadService;

    @GetMapping("/mensajeria")
    public String verComms(
            @RequestParam(defaultValue = "") String query,
            @RequestParam(defaultValue = "TODOS") String canal,
            @RequestParam(defaultValue = "TODOS") String estado,
            @RequestParam(defaultValue = "0") int page,
            Model model) {

        // Paginación ordenada cronológicamente descendiente (los más nuevos primero)
        Pageable pageable = PageRequest.of(page, 10, Sort.by("fecha").descending());
        Page<LogNotificacion> logsPage;

        // Evaluar permutations de filtrado
        boolean hasCanal = !"TODOS".equalsIgnoreCase(canal);
        boolean hasEstado = !"TODOS".equalsIgnoreCase(estado);

        if (hasCanal && hasEstado) {
            logsPage = logNotificacionRepo.buscarLogs(query, canal.toUpperCase(), estado.toUpperCase(), pageable);
        } else if (hasCanal) {
            logsPage = logNotificacionRepo.buscarLogsSinEstado(query, canal.toUpperCase(), pageable);
        } else if (hasEstado) {
            logsPage = logNotificacionRepo.buscarLogsSinTipo(query, estado.toUpperCase(), pageable);
        } else {
            logsPage = logNotificacionRepo.buscarLogsGeneral(query, pageable);
        }

        // Calcular telemetría y porcentajes
        long totalEmails = logNotificacionRepo.countByTipo("EMAIL");
        long totalSms = logNotificacionRepo.countByTipo("SMS");
        long totalWhatsApp = logNotificacionRepo.countByTipo("WHATSAPP");
        long totalSuccess = logNotificacionRepo.countByEstado("SUCCESS");
        long totalFailed = logNotificacionRepo.countByEstado("FAILED");

        long totalComms = totalEmails + totalSms + totalWhatsApp;
        double successRate = totalComms > 0 ? ((double) totalSuccess / totalComms) * 100 : 100.0;
        String formattedSuccessRate = String.format("%.1f", successRate);

        model.addAttribute("logs", logsPage);
        model.addAttribute("query", query);
        model.addAttribute("canal", canal);
        model.addAttribute("estado", estado);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", logsPage.getTotalPages());

        model.addAttribute("totalEmails", totalEmails);
        model.addAttribute("totalSms", totalSms);
        model.addAttribute("totalWhatsApp", totalWhatsApp);
        model.addAttribute("successRate", formattedSuccessRate);

        // Cargar configuración global para navegación y modo mantenimiento
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new ConfiguracionGlobal());
        model.addAttribute("config", config);

        return "admin/mensajeria";
    }

    @PostMapping("/mensajeria/reenviar")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> reenviarNotificacion(@RequestParam String id) {
        Map<String, Object> response = new HashMap<>();
        try {
            LogNotificacion log = logNotificacionRepo.findById(id).orElse(null);
            if (log == null) {
                response.put("success", false);
                response.put("message", "La notificación especificada no fue encontrada.");
                return ResponseEntity.badRequest().body(response);
            }

            // Volver a despachar el mensaje según su tipo/canal original
            if ("EMAIL".equalsIgnoreCase(log.getTipo())) {
                emailService.sendSimpleMessage(log.getDestinatario(), log.getAsunto(), log.getMensaje());
            } else if ("SMS".equalsIgnoreCase(log.getTipo())) {
                smsService.sendSms(log.getDestinatario(), log.getMensaje());
            } else if ("WHATSAPP".equalsIgnoreCase(log.getTipo())) {
                smsService.sendWhatsApp(log.getDestinatario(), log.getMensaje());
            }

            // Registrar log administrativo de auditoría del evento
            logActividadService.registrarAuto(
                "Notificación reenviada", 
                "SISTEMA", 
                "SUCCESS", 
                "Re-envío administrativo forzado de mensaje (" + log.getTipo() + ") al destinatario: " + log.getDestinatario()
            );

            response.put("success", true);
            response.put("message", "Notificación reenviada y procesada con éxito.");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Fallo al procesar el re-envío de la comunicación: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    @PostMapping("/mensajeria/limpiar")
    public String limpiarHistorial() {
        logNotificacionRepo.deleteAll();

        // Registrar acción crítica en bitácora
        logActividadService.registrarAuto(
            "Historial de mensajería purgado", 
            "SISTEMA", 
            "WARNING", 
            "Se ejecutó una purga total del historial de registros de la pasarela de comunicaciones (logs_notificacion)."
        );

        return "redirect:/admin/mensajeria?clearSuccess";
    }
}
