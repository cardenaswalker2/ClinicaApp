package com.clinicaapp.model;

import java.time.LocalDateTime;

public class UserSessionDetails {
    private String sessionId;
    private String username;
    private String ipAddress;
    private String deviceType; // Desktop, Mobile, Tablet
    private String operatingSystem;
    private String browser;
    private LocalDateTime loginTime;
    private LocalDateTime lastActivityTime;

    public UserSessionDetails() {}

    public UserSessionDetails(String sessionId, String username, String ipAddress, String deviceType, 
                              String operatingSystem, String browser, LocalDateTime loginTime) {
        this.sessionId = sessionId;
        this.username = username;
        this.ipAddress = ipAddress;
        this.deviceType = deviceType;
        this.operatingSystem = operatingSystem;
        this.browser = browser;
        this.loginTime = loginTime;
        this.lastActivityTime = loginTime;
    }

    // --- GETTERS & SETTERS ---

    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getDeviceType() { return deviceType; }
    public void setDeviceType(String deviceType) { this.deviceType = deviceType; }

    public String getOperatingSystem() { return operatingSystem; }
    public void setOperatingSystem(String operatingSystem) { this.operatingSystem = operatingSystem; }

    public String getBrowser() { return browser; }
    public void setBrowser(String browser) { this.browser = browser; }

    public LocalDateTime getLoginTime() { return loginTime; }
    public void setLoginTime(LocalDateTime loginTime) { this.loginTime = loginTime; }

    public LocalDateTime getLastActivityTime() { return lastActivityTime; }
    public void setLastActivityTime(LocalDateTime lastActivityTime) { this.lastActivityTime = lastActivityTime; }
}
