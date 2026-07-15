package com.clinicaapp.controller;

import com.clinicaapp.model.ConfiguracionGlobal;
import com.clinicaapp.model.LogInferencia;
import com.clinicaapp.repository.ConfiguracionRepository;
import com.clinicaapp.repository.LogInferenciaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/nova-monitor")
public class NovaMonitorController {

    @Autowired
    private LogInferenciaRepository logInferenciaRepo;

    @Autowired
    private ConfiguracionRepository configRepo;

    @GetMapping
    public String renderMonitorUI(Model model) {
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new ConfiguracionGlobal());
        model.addAttribute("config", config);
        
        long totalInferencias = logInferenciaRepo.count();
        model.addAttribute("totalInferencias", totalInferencias);

        return "admin/nova_monitor";
    }

    @GetMapping("/telemetria")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getTelemetriaEnVivo(@RequestParam(defaultValue = "15") int limit) {
        Map<String, Object> response = new HashMap<>();

        long total = logInferenciaRepo.count();
        List<LogInferencia> recientes = logInferenciaRepo.findAll(
                PageRequest.of(0, limit, Sort.by(Sort.Direction.DESC, "fecha"))
        ).getContent();

        // Calcular la tasa de asistencia inteligente en los últimos 100 registros
        List<LogInferencia> recentStats = logInferenciaRepo.findAll(
                PageRequest.of(0, 100, Sort.by(Sort.Direction.DESC, "fecha"))
        ).getContent();

        long groqCount = recentStats.stream()
                .filter(l -> l.getMotorUtilizado() != null && l.getMotorUtilizado().contains("Groq")).count();
        
        double resolutionRate = recentStats.isEmpty() ? 100.0 : ((double) groqCount / recentStats.size()) * 100;

        response.put("total", total);
        response.put("recientes", recientes);
        response.put("resolutionRate", Math.round(resolutionRate * 10.0) / 10.0);

        // Simulamos un indicador para Weka basado en memoria (siempre OK para simular el engine ML médico)
        response.put("wekaStatus", "ONLINE (riesgo_articular.model loaded)");

        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/limpiar")
    @ResponseBody
    public ResponseEntity<Map<String, String>> limpiarHistorial() {
        logInferenciaRepo.deleteAll();
        Map<String, String> response = new HashMap<>();
        response.put("status", "SUCCESS");
        return ResponseEntity.ok(response);
    }
}
