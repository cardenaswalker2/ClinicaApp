package com.clinicaapp.config;

import org.springframework.stereotype.Component;
import java.security.MessageDigest;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class NetworkDeviceTracker {

    public static class DeviceSession {
        private String id;
        private String name;
        private String ip;
        private String mac;
        private String status; // ACTIVE, IDLE
        private String os;
        private String type; // Mobile, Tablet, PC
        private String latency;
        private String accessTime;
        private long lastAccessMs;
        private boolean simulated;

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getIp() { return ip; }
        public void setIp(String ip) { this.ip = ip; }

        public String getMac() { return mac; }
        public void setMac(String mac) { this.mac = mac; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        public String getOs() { return os; }
        public void setOs(String os) { this.os = os; }

        public String getType() { return type; }
        public void setType(String type) { this.type = type; }

        public String getLatency() { return latency; }
        public void setLatency(String latency) { this.latency = latency; }

        public String getAccessTime() { return accessTime; }
        public void setAccessTime(String accessTime) { this.accessTime = accessTime; }

        public long getLastAccessMs() { return lastAccessMs; }
        public void setLastAccessMs(long lastAccessMs) { this.lastAccessMs = lastAccessMs; }

        public boolean isSimulated() { return simulated; }
        public void setSimulated(boolean simulated) { this.simulated = simulated; }
    }

    private final Map<String, DeviceSession> devices = new ConcurrentHashMap<>();
    private final Set<String> blacklistedIps = ConcurrentHashMap.newKeySet();
    private final Set<String> revokedDeviceIds = ConcurrentHashMap.newKeySet();
    private final java.util.concurrent.atomic.AtomicInteger totalScans = new java.util.concurrent.atomic.AtomicInteger(47);
    private boolean pinRequired = false;
    private final Set<String> pinVerifiedIps = ConcurrentHashMap.newKeySet();

    public NetworkDeviceTracker() {
        seedDefaultDevices();
    }

    public int getTotalScans() {
        return totalScans.get();
    }

    public boolean isPinRequired() {
        return pinRequired;
    }

    public void setPinRequired(boolean pinRequired) {
        this.pinRequired = pinRequired;
        if (!pinRequired) {
            pinVerifiedIps.clear();
        }
    }

    public boolean isIpPinVerified(String ip) {
        return pinVerifiedIps.contains(ip);
    }

    public void verifyIpPin(String ip) {
        pinVerifiedIps.add(ip);
    }

    private void seedDefaultDevices() {
        DeviceSession dev1 = new DeviceSession();
        dev1.setId("dev_1");
        dev1.setName("iPhone 15 Pro");
        dev1.setIp("192.168.1.50");
        dev1.setMac("BC:D1:EC:11:A2:3B");
        dev1.setStatus("ACTIVE");
        dev1.setOs("iOS");
        dev1.setType("Mobile");
        dev1.setLatency("12ms");
        dev1.setAccessTime("Hace 2 minutos");
        dev1.setLastAccessMs(System.currentTimeMillis() - 120000);
        dev1.setSimulated(true);
        devices.put(dev1.getId(), dev1);

        DeviceSession dev2 = new DeviceSession();
        dev2.setId("dev_2");
        dev2.setName("Samsung Galaxy S24");
        dev2.setIp("192.168.1.62");
        dev2.setMac("48:5F:99:A5:72:0D");
        dev2.setStatus("ACTIVE");
        dev2.setOs("Android");
        dev2.setType("Mobile");
        dev2.setLatency("18ms");
        dev2.setAccessTime("Hace 5 minutos");
        dev2.setLastAccessMs(System.currentTimeMillis() - 300000);
        dev2.setSimulated(true);
        devices.put(dev2.getId(), dev2);

        DeviceSession dev3 = new DeviceSession();
        dev3.setId("dev_3");
        dev3.setName("iPad Pro M4");
        dev3.setIp("192.168.1.15");
        dev3.setMac("D4:A3:3D:88:2E:FF");
        dev3.setStatus("IDLE");
        dev3.setOs("iPadOS");
        dev3.setType("Tablet");
        dev3.setLatency("15ms");
        dev3.setAccessTime("Hace 15 minutos");
        dev3.setLastAccessMs(System.currentTimeMillis() - 900000);
        dev3.setSimulated(true);
        devices.put(dev3.getId(), dev3);
    }

    public void registerDevice(String ip, String userAgent) {
        if (blacklistedIps.contains(ip)) {
            return;
        }

        String id = "dev_" + Math.abs((ip + userAgent).hashCode());
        if (revokedDeviceIds.contains(id)) {
            return;
        }

        DeviceSession device = devices.get(id);
        if (device == null) {
            device = new DeviceSession();
            device.setId(id);
            device.setIp(ip);
            device.setMac(generateMacFromIpAndUserAgent(ip, userAgent));
            device.setSimulated(false);
            parseUserAgent(device, userAgent);
            device.setLatency((new Random().nextInt(15) + 3) + "ms");
            totalScans.incrementAndGet();
        }

        device.setLastAccessMs(System.currentTimeMillis());
        device.setStatus("ACTIVE");
        devices.put(id, device);
    }

    public void simulateDevice(String name, String os, String type, String ip, String mac) {
        totalScans.incrementAndGet();
        String id = "dev_sim_" + System.currentTimeMillis() + "_" + new Random().nextInt(1000);
        DeviceSession device = new DeviceSession();
        device.setId(id);
        device.setName(name);
        device.setIp(ip);
        device.setMac(mac);
        device.setOs(os);
        device.setType(type);
        device.setStatus("ACTIVE");
        device.setLatency((new Random().nextInt(20) + 5) + "ms");
        device.setAccessTime("Ahora mismo");
        device.setLastAccessMs(System.currentTimeMillis());
        device.setSimulated(true);
        devices.put(id, device);
    }

    public List<DeviceSession> getActiveDevices() {
        long now = System.currentTimeMillis();
        List<DeviceSession> list = new ArrayList<>();
        
        for (DeviceSession dev : devices.values()) {
            if (revokedDeviceIds.contains(dev.getId())) {
                continue;
            }
            
            if (!dev.isSimulated()) {
                long diff = now - dev.getLastAccessMs();
                if (diff > 15 * 60 * 1000) {
                    dev.setStatus("IDLE");
                } else {
                    dev.setStatus("ACTIVE");
                }
                
                if (diff < 60 * 1000) {
                    dev.setAccessTime("Ahora mismo");
                } else if (diff < 60 * 60 * 1000) {
                    dev.setAccessTime("Hace " + (diff / (60 * 1000)) + " min");
                } else {
                    dev.setAccessTime("Hace " + (diff / (60 * 60 * 1000)) + " horas");
                }
            } else {
                long diff = now - dev.getLastAccessMs();
                if (diff > 10 * 60 * 1000) {
                    dev.setStatus("IDLE");
                }
                
                if (diff < 15 * 1000) {
                    dev.setAccessTime("Ahora mismo");
                } else if (diff < 60 * 1000) {
                    dev.setAccessTime("Hace " + (diff / 1000) + " s");
                } else {
                    dev.setAccessTime("Hace " + (diff / 60000) + " min");
                }
            }
            
            list.add(dev);
        }
        
        list.sort((d1, d2) -> {
            if (d1.getStatus().equals(d2.getStatus())) {
                return Long.compare(d2.getLastAccessMs(), d1.getLastAccessMs());
            }
            return d1.getStatus().equals("ACTIVE") ? -1 : 1;
        });
        
        return list;
    }

    public void revokeDevice(String id) {
        DeviceSession dev = devices.get(id);
        if (dev != null) {
            revokedDeviceIds.add(id);
            if (!dev.isSimulated()) {
                blacklistedIps.add(dev.getIp());
            }
            devices.remove(id);
        } else {
            revokedDeviceIds.add(id);
            devices.remove(id);
        }
    }

    public boolean isBlacklisted(String ip) {
        return blacklistedIps.contains(ip);
    }

    private String generateMacFromIpAndUserAgent(String ip, String userAgent) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hash = md.digest((ip + userAgent).getBytes());
            StringBuilder mac = new StringBuilder();
            for (int i = 0; i < 6; i++) {
                int val = hash[i % hash.length] & 0xFF;
                if (i == 0) {
                    val = (val & 0xFC) | 0x02; // locally administered unicast
                }
                mac.append(String.format("%02X", val));
                if (i < 5) {
                    mac.append(":");
                }
            }
            return mac.toString();
        } catch (Exception e) {
            return "02:00:00:00:00:00";
        }
    }

    private void parseUserAgent(DeviceSession device, String userAgent) {
        String ua = userAgent.toLowerCase();
        if (ua.contains("iphone")) {
            device.setName("iPhone");
            device.setOs("iOS");
            device.setType("Mobile");
        } else if (ua.contains("ipad")) {
            device.setName("iPad");
            device.setOs("iPadOS");
            device.setType("Tablet");
        } else if (ua.contains("android")) {
            device.setOs("Android");
            device.setType("Mobile");
            String model = extractAndroidModel(userAgent);
            if (model != null && !model.isEmpty()) {
                device.setName(model);
            } else {
                device.setName("Dispositivo Android");
            }
        } else if (ua.contains("windows")) {
            device.setName("PC Windows");
            device.setOs("Windows");
            device.setType("PC");
        } else if (ua.contains("macintosh") || ua.contains("mac os")) {
            device.setName("MacBook / iMac");
            device.setOs("macOS");
            device.setType("PC");
        } else if (ua.contains("linux")) {
            device.setName("PC Linux");
            device.setOs("Linux");
            device.setType("PC");
        } else {
            device.setName("Dispositivo Desconocido");
            device.setOs("Desconocido");
            device.setType("Mobile");
        }
    }

    private String extractAndroidModel(String userAgent) {
        try {
            int startIdx = userAgent.indexOf('(');
            int endIdx = userAgent.indexOf(')');
            if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
                String contents = userAgent.substring(startIdx + 1, endIdx);
                String[] parts = contents.split(";");
                
                int androidIdx = -1;
                for (int i = 0; i < parts.length; i++) {
                    if (parts[i].toLowerCase().contains("android")) {
                        androidIdx = i;
                        break;
                    }
                }
                
                if (androidIdx != -1) {
                    for (int i = androidIdx + 1; i < parts.length; i++) {
                        String candidate = parts[i].trim();
                        
                        // Ignore locale tags (like es-es, en-us, es, en)
                        if (candidate.length() <= 5 && (candidate.contains("-") || candidate.contains("_") || candidate.length() <= 3)) {
                            continue;
                        }
                        if (candidate.equalsIgnoreCase("wv")) {
                            continue;
                        }
                        
                        // Clean up Build info
                        if (candidate.toLowerCase().contains("build/")) {
                            int bIdx = candidate.toLowerCase().indexOf("build/");
                            candidate = candidate.substring(0, bIdx).trim();
                        }
                        
                        if (!candidate.isEmpty()) {
                            return mapModelToPrettyName(candidate);
                        }
                    }
                }
            }
        } catch (Exception e) {
            // Ignore
        }
        return null;
    }

    private String mapModelToPrettyName(String model) {
        String modelLower = model.toLowerCase();
        if (model.startsWith("SM-") || modelLower.contains("samsung")) {
            if (model.startsWith("SM-")) {
                return "Samsung Galaxy (" + model + ")";
            }
            return model;
        }
        if (modelLower.contains("pixel")) {
            if (!modelLower.contains("google")) {
                return "Google " + model;
            }
            return model;
        }
        if (modelLower.contains("redmi") || modelLower.contains("xiaomi") || modelLower.contains("poco") || model.startsWith("M2") || model.startsWith("2")) {
            if (model.startsWith("M2") || model.startsWith("2")) {
                return "Xiaomi / Redmi (" + model + ")";
            }
            return model;
        }
        if (model.startsWith("XT") || modelLower.contains("moto")) {
            if (model.startsWith("XT")) {
                return "Motorola Moto (" + model + ")";
            }
            return model;
        }
        if (model.startsWith("CPH") || modelLower.contains("oppo")) {
            if (model.startsWith("CPH")) {
                return "Oppo (" + model + ")";
            }
            return model;
        }
        return model;
    }
}
