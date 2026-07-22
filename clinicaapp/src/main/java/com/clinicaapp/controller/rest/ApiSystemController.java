package com.clinicaapp.controller.rest;

import com.clinicaapp.model.ConfiguracionGlobal;
import com.clinicaapp.repository.ConfiguracionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.clinicaapp.config.NetworkDeviceTracker;
import org.springframework.web.bind.annotation.RequestBody;
import jakarta.servlet.http.HttpServletRequest;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.Enumeration;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/system")
public class ApiSystemController {

    @Autowired
    private ConfiguracionRepository configRepo;

    @Autowired
    private NetworkDeviceTracker deviceTracker;

    @Value("${server.port:8080}")
    private String serverPort;

    @GetMapping("/network")
    public Map<String, Object> getNetworkInfo() {
        Map<String, Object> info = new HashMap<>();
        String ip = getLocalIPv4Address();
        info.put("ip", ip);
        info.put("port", serverPort);
        info.put("url", "http://" + ip + ":" + serverPort);
        info.put("serverStatus", "ONLINE");
        
        // Network name / interface name
        String networkName = "Red Local (Wi-Fi/Ethernet)";
        String interfaceName = "Unknown";
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface iface = interfaces.nextElement();
                if (iface.isLoopback() || !iface.isUp() || iface.isVirtual()) {
                    continue;
                }
                Enumeration<InetAddress> addresses = iface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress addr = addresses.nextElement();
                    if (addr instanceof java.net.Inet4Address && !addr.isLoopbackAddress()) {
                        interfaceName = iface.getName();
                        networkName = iface.getDisplayName();
                        break;
                    }
                }
            }
        } catch (SocketException e) {
            // Ignore
        }
        
        info.put("networkName", networkName);
        info.put("interfaceName", interfaceName);
        info.put("timestamp", java.time.LocalDateTime.now().toString());
        
        // System Uptime
        long uptimeMs = java.lang.management.ManagementFactory.getRuntimeMXBean().getUptime();
        long hours = uptimeMs / (3600 * 1000);
        long minutes = (uptimeMs % (3600 * 1000)) / (60 * 1000);
        info.put("uptime", String.format("%dh %dm", hours, minutes));
        
        // Return real active devices
        info.put("connectedDevices", deviceTracker.getActiveDevices());
        
        // Return all detected local IPv4 interfaces
        info.put("allIps", getAllLocalIPv4Addresses());
        info.put("pinRequired", deviceTracker.isPinRequired());
        
        // Stats
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalScans", deviceTracker.getTotalScans());
        stats.put("activeUsers", deviceTracker.getActiveDevices().stream().filter(d -> d.getStatus().equals("ACTIVE")).count());
        stats.put("networkLoad", "1.2 Mbps");
        stats.put("wifiSignal", "98%");
        info.put("stats", stats);
        
        return info;
    }

    @PostMapping("/revoke")
    public Map<String, Object> revokeDevice(@RequestParam("id") String id) {
        deviceTracker.revokeDevice(id);
        Map<String, Object> response = new HashMap<>();
        response.put("status", "REVOKED");
        response.put("id", id);
        return response;
    }

    @PostMapping("/restore")
    public Map<String, Object> restoreDevice(@RequestParam("id") String id) {
        deviceTracker.restoreDevice(id);
        Map<String, Object> response = new HashMap<>();
        response.put("status", "RESTORED");
        response.put("id", id);
        return response;
    }

    @PostMapping("/verify-pin")
    public Map<String, Object> verifyPin(@RequestParam("pin") String pin, jakarta.servlet.http.HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        if ("1428".equals(pin)) {
            deviceTracker.verifyIpPin(request.getRemoteAddr());
            response.put("success", true);
        } else {
            response.put("success", false);
        }
        return response;
    }

    @PostMapping("/pin-toggle")
    public Map<String, Object> pinToggle(@RequestParam("enabled") boolean enabled) {
        deviceTracker.setPinRequired(enabled);
        Map<String, Object> response = new HashMap<>();
        response.put("pinRequired", enabled);
        return response;
    }

    @PostMapping("/simulate-scan")
    public Map<String, Object> simulateScan() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "DISABLED");
        response.put("message", "Simulated scanning is disabled on production console.");
        return response;
    }

    private List<Map<String, String>> getAllLocalIPv4Addresses() {
        List<Map<String, String>> list = new ArrayList<>();
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface iface = interfaces.nextElement();
                if (iface.isLoopback() || !iface.isUp() || iface.isVirtual()) {
                    continue;
                }
                Enumeration<InetAddress> addresses = iface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress addr = addresses.nextElement();
                    if (addr instanceof java.net.Inet4Address && !addr.isLoopbackAddress()) {
                        String ip = addr.getHostAddress();
                        if (!ip.startsWith("169.254")) {
                            Map<String, String> item = new HashMap<>();
                            item.put("ip", ip);
                            item.put("name", iface.getDisplayName() + " (" + iface.getName() + ")");
                            list.add(item);
                        }
                    }
                }
            }
        } catch (SocketException e) {
            // Ignore
        }
        
        if (list.isEmpty()) {
            Map<String, String> item = new HashMap<>();
            item.put("ip", "127.0.0.1");
            item.put("name", "Loopback (localhost)");
            list.add(item);
        }
        return list;
    }

    private String getLocalIPv4Address() {
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface iface = interfaces.nextElement();
                if (iface.isLoopback() || !iface.isUp() || iface.isVirtual()) {
                    continue;
                }
                Enumeration<InetAddress> addresses = iface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress addr = addresses.nextElement();
                    if (addr instanceof java.net.Inet4Address && !addr.isLoopbackAddress()) {
                        String ip = addr.getHostAddress();
                        if (!ip.startsWith("169.254")) {
                            return ip;
                        }
                    }
                }
            }
        } catch (SocketException e) {
            // Fallback
        }
        try {
            return InetAddress.getLocalHost().getHostAddress();
        } catch (UnknownHostException e) {
            return "127.0.0.1";
        }
    }

    @GetMapping("/status")
    public Map<String, Object> getStatus() {
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new ConfiguracionGlobal());
        
        Map<String, Object> status = new HashMap<>();
        status.put("modoMantenimiento", config.isModoMantenimiento());
        status.put("mensajeGlobal", config.getMensajeGlobal());
        status.put("broadcastColor", config.getBroadcastColor());
        status.put("broadcastActivo", config.isBroadcastActivo());
        status.put("minutosParaCierre", config.getMinutosParaCierre());
        status.put("mantenimientoDesde", config.getMantenimientoDesde() != null ? config.getMantenimientoDesde().toString() : null);
        
        // Calcular tiempo restante y progreso en base a la hora de activación real
        long remainingSeconds = 900; // 15 minutos de base
        double maintenanceProgress = 0.0;
        
        if (config.isModoMantenimiento() && config.getMantenimientoDesde() != null) {
            long totalWindowSeconds = 900; // Ventana total de 15 minutos
            java.time.Duration duration = java.time.Duration.between(config.getMantenimientoDesde(), java.time.LocalDateTime.now());
            long elapsedSeconds = duration.getSeconds();
            
            if (elapsedSeconds < 0) elapsedSeconds = 0;
            
            remainingSeconds = totalWindowSeconds - elapsedSeconds;
            if (remainingSeconds < 0) remainingSeconds = 0;
            
            maintenanceProgress = ((double) elapsedSeconds / totalWindowSeconds) * 100.0;
            if (maintenanceProgress > 98.0) maintenanceProgress = 98.0; // Mantener en 98% máximo antes de reactivar
            if (maintenanceProgress < 0) maintenanceProgress = 0;
        }
        
        status.put("remainingSeconds", remainingSeconds);
        status.put("maintenanceProgress", maintenanceProgress);
        
        return status;
    }

    @PostMapping("/telemetry")
    public Map<String, Object> updateDeviceTelemetry(@RequestBody Map<String, Object> telemetry, HttpServletRequest request) {
        String ip = request.getHeader("CF-Connecting-IP");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Forwarded-For");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }

        deviceTracker.updateTelemetry(ip, telemetry);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        return response;
    }
}
