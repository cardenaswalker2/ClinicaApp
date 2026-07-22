package com.clinicaapp.service;

import com.clinicaapp.model.UserSessionDetails;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class UserSessionTracker {

    private final Map<String, UserSessionDetails> activeSessions = new ConcurrentHashMap<>();

    public void registerSession(String sessionId, String username, String ipAddress, String userAgent) {
        String deviceType = "Desktop";
        String operatingSystem = "Unknown OS";
        String browser = "Unknown Browser";

        if (userAgent != null) {
            String ua = userAgent.toLowerCase();

            // Detect Device Type
            if (ua.contains("mobile") || ua.contains("android") || ua.contains("iphone") || ua.contains("ipod")) {
                deviceType = "Mobile";
            } else if (ua.contains("ipad") || ua.contains("tablet") || (ua.contains("android") && !ua.contains("mobile"))) {
                deviceType = "Tablet";
            }

            // Detect Operating System
            if (ua.contains("windows")) {
                operatingSystem = "Windows";
            } else if (ua.contains("macintosh") || ua.contains("mac os")) {
                operatingSystem = "macOS";
            } else if (ua.contains("iphone") || ua.contains("ipad") || ua.contains("ipod")) {
                operatingSystem = "iOS";
            } else if (ua.contains("android")) {
                operatingSystem = "Android";
            } else if (ua.contains("linux")) {
                operatingSystem = "Linux";
            }

            // Detect Browser
            if (ua.contains("edg/") || ua.contains("edge")) {
                browser = "Microsoft Edge";
            } else if (ua.contains("chrome") || ua.contains("crios")) {
                // Chrome contains safari and mobile, so check chrome first
                browser = "Google Chrome";
            } else if (ua.contains("firefox") || ua.contains("fxios")) {
                browser = "Mozilla Firefox";
            } else if (ua.contains("safari") && !ua.contains("chrome") && !ua.contains("android")) {
                browser = "Apple Safari";
            } else if (ua.contains("opera") || ua.contains("opr/")) {
                browser = "Opera";
            }
        }

        UserSessionDetails details = new UserSessionDetails(
                sessionId,
                username,
                ipAddress,
                deviceType,
                operatingSystem,
                browser,
                LocalDateTime.now()
        );

        activeSessions.put(sessionId, details);
    }

    public void removeSession(String sessionId) {
        activeSessions.remove(sessionId);
    }

    public void updateActivity(String sessionId) {
        UserSessionDetails details = activeSessions.get(sessionId);
        if (details != null) {
            details.setLastActivityTime(LocalDateTime.now());
        }
    }

    public UserSessionDetails getSessionDetails(String sessionId) {
        return activeSessions.get(sessionId);
    }

    public Collection<UserSessionDetails> getAllActiveSessions() {
        return activeSessions.values();
    }
}
