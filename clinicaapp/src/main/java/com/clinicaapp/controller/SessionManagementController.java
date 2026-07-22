package com.clinicaapp.controller;

import com.clinicaapp.model.UserSessionDetails;
import com.clinicaapp.service.UserSessionTracker;
import com.clinicaapp.service.LogActividadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.session.SessionInformation;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@Controller
@RequestMapping("/admin/sesiones")
public class SessionManagementController {

    @Autowired
    private SessionRegistry sessionRegistry;

    @Autowired
    private UserSessionTracker sessionTracker;

    @Autowired
    private LogActividadService logActividadService;

    @GetMapping
    public String viewSessions(Model model) {
        return "admin/sesiones";
    }

    @GetMapping("/api/activas")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getActiveSessions() {
        List<Map<String, Object>> result = new ArrayList<>();
        List<Object> principals = sessionRegistry.getAllPrincipals();

        for (Object principal : principals) {
            List<SessionInformation> sessions = sessionRegistry.getAllSessions(principal, false);
            for (SessionInformation session : sessions) {
                Map<String, Object> data = new HashMap<>();
                String sessionId = session.getSessionId();
                data.put("sessionId", sessionId);
                
                // Extract clean username/principal representation
                String username = session.getPrincipal().toString();
                if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
                    username = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
                } else if (principal instanceof org.springframework.security.oauth2.core.user.OAuth2User) {
                    username = ((org.springframework.security.oauth2.core.user.OAuth2User) principal).getAttribute("email");
                    if (username == null) {
                        username = ((org.springframework.security.oauth2.core.user.OAuth2User) principal).getName();
                    }
                }
                
                data.put("username", username);
                data.put("lastRequest", session.getLastRequest());
                data.put("expired", session.isExpired());

                UserSessionDetails trackerDetails = sessionTracker.getSessionDetails(sessionId);
                if (trackerDetails != null) {
                    data.put("ipAddress", trackerDetails.getIpAddress());
                    data.put("deviceType", trackerDetails.getDeviceType());
                    data.put("operatingSystem", trackerDetails.getOperatingSystem());
                    data.put("browser", trackerDetails.getBrowser());
                    data.put("loginTime", trackerDetails.getLoginTime());
                } else {
                    data.put("ipAddress", "IP Desconocida");
                    data.put("deviceType", "Desktop");
                    data.put("operatingSystem", "OS Desconocido");
                    data.put("browser", "Browser Desconocido");
                    data.put("loginTime", LocalDateTime.now());
                }
                result.add(data);
            }
        }
        return ResponseEntity.ok(result);
    }

    @PostMapping("/revocar")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> revokeSession(@RequestParam String sessionId) {
        Map<String, Object> response = new HashMap<>();
        SessionInformation sessionInfo = sessionRegistry.getSessionInformation(sessionId);

        if (sessionInfo != null) {
            String username = sessionInfo.getPrincipal().toString();
            if (sessionInfo.getPrincipal() instanceof org.springframework.security.core.userdetails.UserDetails) {
                username = ((org.springframework.security.core.userdetails.UserDetails) sessionInfo.getPrincipal()).getUsername();
            }
            
            sessionInfo.expireNow();
            
            // Registrar actividad de revocación
            try {
                logActividadService.registrarAuto(
                    "Cierre remoto de sesión para " + username,
                    "SEGURIDAD",
                    "WARNING",
                    "El administrador forzó el cierre de la sesión " + sessionId
                );
            } catch (Exception e) {
                // ignore
            }

            sessionTracker.removeSession(sessionId);
            response.put("success", true);
            response.put("message", "La sesión fue revocada exitosamente.");
        } else {
            response.put("success", false);
            response.put("message", "No se encontró la sesión especificada o ya expiró.");
        }

        return ResponseEntity.ok(response);
    }
}
