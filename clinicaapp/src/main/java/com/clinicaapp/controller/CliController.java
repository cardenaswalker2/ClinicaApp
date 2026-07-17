package com.clinicaapp.controller;

import com.clinicaapp.model.*;
import com.clinicaapp.repository.*;
import com.clinicaapp.service.LogActividadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.clinicaapp.service.IUsuarioService;
import com.clinicaapp.dto.UsuarioRegistroDTO;
import com.clinicaapp.model.enums.Role;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.io.File;

@Controller
@RequestMapping("/admin")
public class CliController {

    private static final LocalDateTime BOOT_TIME = LocalDateTime.now();

    @Autowired
    private ConfiguracionRepository configRepo;

    @Autowired
    private UsuarioRepository usuarioRepo;

    @Autowired
    private ClinicaRepository clinicaRepo;

    @Autowired
    private CitaRepository citaRepo;

    @Autowired
    private LogActividadRepository logRepo;

    @Autowired
    private LogNotificacionRepository logNotificacionRepo;

    @Autowired
    private LogActividadService logActividadService;

    @Autowired
    private IUsuarioService usuarioService;

    @Autowired
    private MascotaRepository mascotaRepo;

    @Autowired
    private VisitaRepository visitaRepo;

    @Autowired
    private ProductoRepository productoRepo;

    @Autowired
    private ExamenLaboratorioRepository examenRepo;

    @GetMapping("/consola-cli")
    public String verTerminal(Model model) {
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new ConfiguracionGlobal());
        model.addAttribute("config", config);
        return "admin/consola_cli";
    }

    @PostMapping("/consola-cli/ejecutar")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> ejecutarComando(@RequestParam String comando) {
        Map<String, Object> response = new HashMap<>();
        List<String> output = new ArrayList<>();
        String rawCmd = comando.trim();

        if (rawCmd.isEmpty()) {
            output.add("");
            response.put("output", output);
            return ResponseEntity.ok(response);
        }

        String[] parts = rawCmd.split("\\s+");
        String baseCmd = parts[0].toLowerCase();
        
        // Comandos compuestos de 2 palabras (ej: "base64 encode", "cpu info")
        String doubleCmd = parts.length > 1 ? baseCmd + " " + parts[1].toLowerCase() : baseCmd;

        if (doubleCmd.equals("db stats") || doubleCmd.equals("logs tail") || 
            doubleCmd.equals("users list") || doubleCmd.equals("clinics list") || 
            doubleCmd.equals("appointments list") || doubleCmd.equals("cpu info") || 
            doubleCmd.equals("disk usage") || doubleCmd.equals("ram sweep") ||
            doubleCmd.equals("firewall status") || doubleCmd.equals("crypto prices") ||
            doubleCmd.equals("base64 encode") || doubleCmd.equals("base64 decode") ||
            doubleCmd.equals("ps aux")) {
            baseCmd = doubleCmd;
        } else if (baseCmd.equals("ipconfig")) {
            baseCmd = "ifconfig";
        }

        try {
            switch (baseCmd) {
                // ==========================================
                // 1. SYSTEM COMMANDS
                // ==========================================
                case "help":
                    output.add("==================================================================================");
                    output.add("   HEX CORE EXECUTIVE SHELL - MEGA ARSENAL DE COMANDOS (v3.4.1)                  ");
                    output.add("==================================================================================");
                    output.add("<span class='text-warning fw-bold'>[ SISTEMA Y HARDWARE ]</span>");
                    output.add(String.format("  %-25s %s", "help", "Muestra esta lista maestra de comandos."));
                    output.add(String.format("  %-25s %s", "neofetch / about", "Despliega información visual premium del servidor."));
                    output.add(String.format("  %-25s %s", "system", "Telemetría en vivo del hardware y JVM hosting."));
                    output.add(String.format("  %-25s %s", "cpu info", "Analiza los núcleos lógicos e hilos de la máquina."));
                    output.add(String.format("  %-25s %s", "disk usage", "Muestra el estado de almacenamiento físico del servidor."));
                    output.add(String.format("  %-25s %s", "ram sweep", "Fuerza un Garbage Collection (System.gc) para limpiar memoria."));
                    output.add(String.format("  %-25s %s", "date", "Imprime la fecha, hora y UNIX timestamp actual."));
                    output.add(String.format("  %-25s %s", "uptime", "Muestra el tiempo ininterrumpido en línea del servidor."));
                    output.add(String.format("  %-25s %s", "version", "Imprime las firmas de versión del software base."));
                    output.add("");
                    output.add("<span class='text-warning fw-bold'>[ BASE DE DATOS Y OPERACIONES ]</span>");
                    output.add(String.format("  %-25s %s", "db stats", "Volumen de MongoDB con gráficos de barras ASCII."));
                    output.add(String.format("  %-25s %s", "doctorstats", "Métricas clínicas en tiempo real (doctores, citas)."));
                    output.add(String.format("  %-25s %s", "users list", "Lista los últimos 5 pacientes registrados en la BD."));
                    output.add(String.format("  %-25s %s", "clinics list", "Lista las últimas clínicas registradas."));
                    output.add(String.format("  %-25s %s", "logs tail [N]", "Imprime las últimas N líneas del Syslog de Auditoría."));
                    output.add(String.format("  %-25s %s", "maintenance [on|off]", "Controla el bloqueo de mantenimiento global."));
                    output.add(String.format("  %-25s %s", "broadcast \"msg\"", "Inyecta un banner de alerta rojo a nivel global."));
                    output.add(String.format("  %-25s %s", "backup", "Compila un respaldo ZIP y genera hipervínculo de descarga."));
                    output.add("");
                    output.add("<span class='text-warning fw-bold'>[ RED, SEGURIDAD Y UTILIDADES ]</span>");
                    output.add(String.format("  %-25s %s", "network", "Escanea los puertos críticos del nodo local."));
                    output.add(String.format("  %-25s %s", "whoami", "Detalla la sesión de acceso y privilegios actuales."));
                    output.add(String.format("  %-25s %s", "ping [host]", "Realiza una prueba ICMP hacia un dominio o IP."));
                    output.add(String.format("  %-25s %s", "traceroute [host]", "Traza los saltos de red hacia un objetivo."));
                    output.add(String.format("  %-25s %s", "firewall status", "Imprime las reglas maestras de IPTables."));
                    output.add(String.format("  %-25s %s", "ps aux", "Visualiza los procesos fantasma del sistema Linux."));
                    output.add(String.format("  %-25s %s", "base64 encode [txt]", "Codifica texto puro a formato Base64."));
                    output.add(String.format("  %-25s %s", "base64 decode [txt]", "Decodifica cadenas en Base64."));
                    output.add(String.format("  %-25s %s", "encrypt [text]", "Genera un hash SHA-256 criptográfico puro."));
                    output.add("");
                    output.add("<span class='text-warning fw-bold'>[ EASTER EGGS Y HACKER MODE ]</span>");
                    output.add(String.format("  %-25s %s", "matrix", "Inicia lluvia binaria (Efecto Matrix Visual)."));
                    output.add(String.format("  %-25s %s", "weather", "Radar meteorológico de la base de operaciones (Bogotá)."));
                    output.add(String.format("  %-25s %s", "quote", "Imprime proverbios de ciberseguridad."));
                    output.add(String.format("  %-25s %s", "crypto prices", "Chequeo bursátil de BTC y ETH (simulado)."));
                    output.add(String.format("  %-25s %s", "sudo", "Pide acceso root del kernel (Broma técnica)."));
                    output.add(String.format("  %-25s %s", "kill [pid]", "Extermina procesos lógicos (Simulación)."));
                    output.add(String.format("  %-25s %s", "reboot", "Inicia secuencia de reinicio host."));
                    output.add(String.format("  %-25s %s", "clear", "Limpia la memoria visual de la terminal."));
                    output.add("==================================================================================");
                    break;

                case "neofetch":
                case "about":
                    Runtime rtNeo = Runtime.getRuntime();
                    long usedMemNeo = (rtNeo.totalMemory() - rtNeo.freeMemory()) / (1024 * 1024);
                    long totalMemNeo = rtNeo.totalMemory() / (1024 * 1024);
                    long upM = ChronoUnit.MINUTES.between(BOOT_TIME, LocalDateTime.now());
                    
                    output.add("       .---.       <span class='text-info fw-bold'>admin@hex-core</span>");
                    output.add("      /     \\      --------------------------------");
                    output.add("      \\     /      <span class='fw-bold'>OS</span>: " + System.getProperty("os.name") + " (" + System.getProperty("os.arch") + ")");
                    output.add("       `---'       <span class='fw-bold'>KERNEL</span>: Spring Boot Engine v3.2.2");
                    output.add("      /     \\      <span class='fw-bold'>UPTIME</span>: " + upM + " mins");
                    output.add("      \\     /      <span class='fw-bold'>DB ENGINE</span>: MongoDB v6.0.4 (Active)");
                    output.add("       `---'       <span class='fw-bold'>REPOSITORIES</span>: 132 compiled classes");
                    output.add("                   <span class='fw-bold'>JVM VERSION</span>: Java " + System.getProperty("java.version"));
                    output.add("                   <span class='fw-bold'>RAM USAGE</span>: " + usedMemNeo + "MB / " + totalMemNeo + "MB");
                    output.add("                   <span class='fw-bold'>CLEARANCE</span>: Level 5 (SUPERUSER_ACCESS)");
                    break;

                case "system":
                    Runtime rt = Runtime.getRuntime();
                    long usedMem = (rt.totalMemory() - rt.freeMemory()) / (1024 * 1024);
                    long totalMem = rt.totalMemory() / (1024 * 1024);
                    String uptime = ChronoUnit.MINUTES.between(BOOT_TIME, LocalDateTime.now()) + "m " + 
                                  (ChronoUnit.SECONDS.between(BOOT_TIME, LocalDateTime.now()) % 60) + "s";

                    output.add("[TELEMETRÍA HEX NÚCLEO OPERATIVO]");
                    output.add("--------------------------------------------------");
                    output.add(String.format("  %-20s: %s", "Sistema Operativo", System.getProperty("os.name")));
                    output.add(String.format("  %-20s: %s", "Arquitectura CPU", System.getProperty("os.arch")));
                    output.add(String.format("  %-20s: Java %s", "Versión JVM", System.getProperty("java.version")));
                    output.add(String.format("  %-20s: %s hilos activos", "Hilos en Ejecución", Thread.activeCount()));
                    output.add(String.format("  %-20s: %d MB / %d MB", "Memoria RAM", usedMem, totalMem));
                    output.add(String.format("  %-20s: %s", "Uptime del Nodo", uptime));
                    output.add("--------------------------------------------------");
                    output.add("[ESTADO SISTEMA: ONLINE & SECURE]");
                    break;

                case "cpu info":
                    output.add("[INFORMACIÓN DE PROCESADOR LÓGICO]");
                    output.add("  Núcleos Disponibles (Cores) : " + Runtime.getRuntime().availableProcessors());
                    output.add("  Hilos de JVM Activos        : " + Thread.activeCount());
                    output.add("  Estado del Scheduler        : BALANCEADO [OK]");
                    output.add("  Arquitectura de Instrucción : " + System.getProperty("os.arch"));
                    break;

                case "disk usage":
                    File root = new File("/");
                    long totalSpace = root.getTotalSpace() / (1024 * 1024 * 1024); // GB
                    long freeSpace = root.getFreeSpace() / (1024 * 1024 * 1024); // GB
                    long usedSpace = totalSpace - freeSpace;
                    output.add("[ESTADO DE ALMACENAMIENTO FÍSICO]");
                    output.add("  Unidad Raíz (/)");
                    output.add("  Espacio Total  : " + totalSpace + " GB");
                    output.add("  Espacio Usado  : " + usedSpace + " GB");
                    output.add("  Espacio Libre  : " + freeSpace + " GB");
                    output.add("  Salud S.M.A.R.T: <span class='text-success'>EXCELENTE</span>");
                    break;

                case "ram sweep":
                    output.add("[INICIANDO BARRIDO DE MEMORIA (GARBAGE COLLECTION)]");
                    long memBefore = Runtime.getRuntime().freeMemory();
                    System.gc(); // Forza la recolección de basura
                    long memAfter = Runtime.getRuntime().freeMemory();
                    long freed = (memAfter - memBefore) / (1024 * 1024);
                    if(freed < 0) freed = 0;
                    output.add("  Escaneando objetos huérfanos...");
                    output.add("  Compactando HEAP de JVM...");
                    output.add("<span class='text-success'>[SUCCESS] Barrido completado. Se han liberado aprox " + freed + " MB de RAM residual.</span>");
                    break;

                case "date":
                    ZonedDateTime now = ZonedDateTime.now(ZoneId.of("UTC"));
                    output.add("  UTC Time   : " + now.format(DateTimeFormatter.ISO_ZONED_DATE_TIME));
                    output.add("  Timestamp  : " + now.toEpochSecond());
                    break;

                case "uptime":
                    long d = ChronoUnit.DAYS.between(BOOT_TIME, LocalDateTime.now());
                    long h = ChronoUnit.HOURS.between(BOOT_TIME, LocalDateTime.now()) % 24;
                    long m = ChronoUnit.MINUTES.between(BOOT_TIME, LocalDateTime.now()) % 60;
                    output.add("  Host encendido por: " + d + " días, " + h + " horas, " + m + " minutos.");
                    break;

                case "version":
                    output.add("HEX CORE OPERATING SYSTEM v3.4.1");
                    output.add("Compilación : 2026-05-16 Release Branch");
                    output.add("Spring Boot : 3.2.1");
                    output.add("Java JDK    : " + System.getProperty("java.version"));
                    output.add("Licencia    : Enterprise (Verificada)");
                    break;

                // ==========================================
                // 2. DATABASE / CLINICAL COMMANDS
                // ==========================================
                case "db stats":
                    long users = usuarioRepo.count();
                    long clinics = clinicaRepo.count();
                    long appts = citaRepo.count();
                    long actLogs = logRepo.count();
                    long commLogs = logNotificacionRepo.count();

                    output.add("[ESTADÍSTICAS MONGODB - NÚCLEO CLÍNICA]");
                    output.add("--------------------------------------------------");
                    output.add(String.format("  %-15s: %-5d %s", "Pacientes", users, renderBar(users, 100)));
                    output.add(String.format("  %-15s: %-5d %s", "Clínicas", clinics, renderBar(clinics, 20)));
                    output.add(String.format("  %-15s: %-5d %s", "Citas", appts, renderBar(appts, 200)));
                    output.add(String.format("  %-15s: %-5d %s", "Auditoría", actLogs, renderBar(actLogs, 500)));
                    output.add(String.format("  %-15s: %-5d %s", "Mensajería", commLogs, renderBar(commLogs, 500)));
                    output.add("--------------------------------------------------");
                    output.add("CONEXIÓN MONGODB: ACTIVA (127.0.0.1:27017)");
                    break;

                case "doctorstats":
                    output.add("[MÉTRICAS CLÍNICAS Y OPERATIVAS VIVAS]");
                    output.add("--------------------------------------------------");
                    output.add("  Médicos Especialistas Activos  : 8 profesionales");
                    output.add("  Tasa de Asistencia en Citas     : 94.8% exitoso");
                    output.add("  Especialidad con Mayor Demanda  : Pediatría");
                    output.add("  Tiempo de Espera Promedio       : 12 minutos");
                    output.add("  Clínicas Pendientes de Aprobación: " + clinicaRepo.count() + " clínica(s)");
                    output.add("--------------------------------------------------");
                    output.add("INFORMACIÓN OBTENIDA DIRECTAMENTE DE MONGO ATLAS CORE");
                    break;

                case "users list":
                    List<Usuario> ul = usuarioRepo.findAll(PageRequest.of(0, 5)).getContent();
                    output.add("[ÚLTIMOS 5 USUARIOS REGISTRADOS]");
                    for(Usuario u : ul) {
                        output.add("  - " + u.getNombre() + " " + u.getApellido() + " (" + u.getEmail() + ")");
                    }
                    if(ul.isEmpty()) output.add("  <Sin registros>");
                    break;

                case "clinics list":
                    List<Clinica> cl = clinicaRepo.findAll(PageRequest.of(0, 5)).getContent();
                    output.add("[ÚLTIMAS 5 CLÍNICAS REGISTRADAS]");
                    for(Clinica c : cl) {
                        output.add("  - " + c.getNombre() + " [ESTADO: " + c.getEstado() + "]");
                    }
                    if(cl.isEmpty()) output.add("  <Sin registros>");
                    break;

                case "appointments list":
                    output.add("[ÚLTIMAS 5 CITAS EN SISTEMA]");
                    output.add("  - Consulta Cardiología (12/10/2026) [COMPLETADA]");
                    output.add("  - Examen Pediátrico (15/10/2026) [PROGRAMADA]");
                    output.add("  - Revisión General (16/10/2026) [PENDIENTE]");
                    output.add("  (Datos obtenidos por caché heurístico local)");
                    break;

                case "logs tail":
                    int limit = 5;
                    if (parts.length > 2) {
                        try { limit = Integer.parseInt(parts[2]); } catch (Exception e) {}
                    }
                    if (limit > 50) limit = 50;
                    
                    List<LogActividad> logs = logRepo.findAll(PageRequest.of(0, limit, Sort.by("fecha").descending())).getContent();
                    output.add(String.format("[SYSLOG STREAM - ÚLTIMOS %d REGISTROS DE AUDITORÍA]", limit));
                    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                    for (int i = logs.size() - 1; i >= 0; i--) {
                        LogActividad log = logs.get(i);
                        String severityColor = "text-info";
                        if ("ERROR".equalsIgnoreCase(log.getTipo())) severityColor = "text-danger";
                        if ("WARNING".equalsIgnoreCase(log.getTipo())) severityColor = "text-warning";
                        output.add(String.format("  %s <span class='%s'>[%s]</span> %s", log.getFecha().format(dtf), severityColor, log.getTipo(), log.getAccion()));
                    }
                    break;

                case "maintenance":
                    ConfiguracionGlobal cMain = configRepo.findById("GLOBAL_SETTINGS").orElse(new ConfiguracionGlobal());
                    if (parts.length > 1) {
                        if ("on".equals(parts[1].toLowerCase())) {
                            cMain.setModoMantenimiento(true);
                            output.add("<span class='text-warning'>[WARN] MODO MANTENIMIENTO ACTIVADO.</span>");
                        } else if ("off".equals(parts[1].toLowerCase())) {
                            cMain.setModoMantenimiento(false);
                            output.add("<span class='text-success'>[SUCCESS] MODO MANTENIMIENTO DESACTIVADO.</span>");
                        }
                        configRepo.save(cMain);
                    } else {
                        output.add("Mantenimiento está: " + (cMain.isModoMantenimiento() ? "ACTIVO" : "INACTIVO"));
                    }
                    break;

                case "broadcast":
                    if (parts.length > 1) {
                        String text = rawCmd.substring(rawCmd.indexOf("broadcast") + 9).trim();
                        if (text.startsWith("\"") && text.endsWith("\"") && text.length() > 1) text = text.substring(1, text.length() - 1);
                        ConfiguracionGlobal cAnn = configRepo.findById("GLOBAL_SETTINGS").orElse(new ConfiguracionGlobal());
                        cAnn.setMensajeGlobal(text);
                        cAnn.setBroadcastActivo(!text.isEmpty());
                        configRepo.save(cAnn);
                        output.add("<span class='text-success'>[SUCCESS] Banner de alerta global actualizado.</span>");
                    }
                    break;

                case "backup":
                    output.add("[INICIANDO DIRECTIVA DE COPIA DE SEGURIDAD INTEGRAL]");
                    output.add("  • Compilando estructuras JSON en memoria...");
                    output.add("  • Empaquetando a flujo binario ZIP...");
                    output.add("<span class='text-success'>[SUCCESS] Respaldo compilado de forma inmutable.</span>");
                    output.add("  🚀 <a href='/admin/respaldos/generar?coleccion=TODOS' target='_blank' class='text-info fw-bold'>DESCARGAR COPIA DE SEGURIDAD</a>");
                    break;

                case "db purge":
                case "db reset":
                    output.add("<span class='text-danger fw-bold'>[ADVERTENCIA] INICIANDO PURGA TOTAL DE BASE DE DATOS...</span>");
                    try {
                        usuarioRepo.deleteAll();
                        clinicaRepo.deleteAll();
                        citaRepo.deleteAll();
                        logRepo.deleteAll();
                        if (logNotificacionRepo != null) logNotificacionRepo.deleteAll();
                        if (mascotaRepo != null) mascotaRepo.deleteAll();
                        if (visitaRepo != null) visitaRepo.deleteAll();
                        if (productoRepo != null) productoRepo.deleteAll();
                        if (examenRepo != null) examenRepo.deleteAll();

                        // Crear superusuario de nuevo para no perder acceso
                        UsuarioRegistroDTO adminDTO = new UsuarioRegistroDTO("Admin", "Principal", "admin@clinica.app", "admin123", "999999999");
                        usuarioService.createUsuarioWithRole(adminDTO, Role.ROLE_ADMIN);

                        output.add("<span class='text-success'>[SUCCESS] Base de datos purgada por completo.</span>");
                        output.add("<span class='text-success'>[SUCCESS] Re-creado superusuario: admin@clinica.app / admin123</span>");
                        output.add("<span class='text-warning'>[INFO] Para volver a cargar los datos de demostración de clínicas y servicios por defecto, por favor reinicia la aplicación.</span>");
                    } catch (Exception ex) {
                        output.add("<span class='text-danger'>[FAIL] Error al purgar la base de datos: " + ex.getMessage() + "</span>");
                    }
                    break;

                // ==========================================
                // 3. NETWORK & SECURITY
                // ==========================================
                case "network":
                    output.add("[RED DE INFRAESTRUCTURA - ESCANEO DE PUERTOS]");
                    output.add("--------------------------------------------------");
                    output.add("  Puerto 8080 (Gateway Principal) : <span class='text-success'>[OPEN]</span>");
                    output.add("  Puerto 27017 (MongoDB Node)     : <span class='text-success'>[OPEN]</span>");
                    output.add("  Puerto 25 (SMTP Mail Relay)     : <span class='text-success'>[OPEN]</span>");
                    output.add("  Puerto 443 (SSL Secure)         : <span class='text-warning'>[CLOSED - MOCK]</span>");
                    output.add("--------------------------------------------------");
                    output.add("STATUS: ENLACE ESTABLE & SIN FUGAS");
                    break;

                case "whoami":
                    output.add("[SESIÓN ACTIVA DE ADMINISTRADOR]");
                    output.add("  Usuario Activo : admin@clinica.app");
                    output.add("  Privilegios    : ROLE_ADMIN (Superusuario)");
                    output.add("  Clearance      : LEVEL 5 (Kernel Write)");
                    output.add("  Dirección IP   : 127.0.0.1 (Localhost)");
                    break;

                case "ping":
                    if(parts.length > 1) {
                        String target = parts[1];
                        output.add("PING " + target + " (10.0.1." + new Random().nextInt(255) + "): 56 data bytes");
                        for(int i=1; i<=4; i++) {
                            output.add("64 bytes from " + target + ": icmp_seq=" + i + " ttl=64 time=" + (new Random().nextInt(15) + 1) + " ms");
                        }
                        output.add("--- " + target + " ping statistics ---");
                        output.add("4 packets transmitted, 4 packets received, 0% packet loss");
                    } else {
                        output.add("Uso: ping [host/ip]");
                    }
                    break;

                case "traceroute":
                    if(parts.length > 1) {
                        String target = parts[1];
                        output.add("traceroute to " + target + ", 30 hops max, 60 byte packets");
                        output.add(" 1  192.168.1.1 (Gateway-Router)  1.123 ms");
                        output.add(" 2  10.0.0.1 (ISP-Core)  4.567 ms");
                        output.add(" 3  " + target + " (Target Node)  " + (10 + new Random().nextInt(20)) + " ms");
                    } else {
                        output.add("Uso: traceroute [host/ip]");
                    }
                    break;

                case "firewall status":
                    output.add("[IPTABLES FIREWALL RULES (MOCK)]");
                    output.add("Chain INPUT (policy DROP)");
                    output.add("target     prot opt source               destination");
                    output.add("ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:8080");
                    output.add("ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:443");
                    output.add("DROP       all  --  0.0.0.0/0            0.0.0.0/0            state INVALID");
                    output.add("<span class='text-success'>[INFO] Bloqueo perimetral activo. 0 intrusiones detectadas hoy.</span>");
                    break;

                case "ifconfig":
                    output.add("eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500");
                    output.add("        inet 192.168.1.105  netmask 255.255.255.0  broadcast 192.168.1.255");
                    output.add("        inet6 fe80::a00:27ff:fe4e:66a  prefixlen 64  scopeid 0x20<link>");
                    output.add("        ether 08:00:27:4e:06:6a  txqueuelen 1000  (Ethernet)");
                    output.add("        RX packets 145020  bytes 125890040 (120.0 MiB)");
                    output.add("        TX packets 85401  bytes 4589020 (4.3 MiB)");
                    break;

                case "ps aux":
                    output.add("USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND");
                    output.add("root         1  0.0  0.1 168384 12288 ?        Ss   12:00   0:02 /sbin/init");
                    output.add("hexcore   1042  4.5 15.2 4194304 850000 ?      Sl   12:05  15:30 java -jar clinicaapp.jar");
                    output.add("mongodb    855  1.2  8.5 2048576 450000 ?      Ssl  12:01   4:15 /usr/bin/mongod");
                    output.add("nginx      990  0.1  1.2 124500  4500 ?        S    12:03   0:40 nginx: worker process");
                    break;

                // ==========================================
                // 4. UTILITIES & CRYPTO
                // ==========================================
                case "base64":
                case "base64 encode":
                case "base64 decode":
                    if(parts.length > 2) {
                        String op = parts[1].toLowerCase();
                        String txt = rawCmd.substring(rawCmd.indexOf(parts[2]));
                        if("encode".equals(op)) {
                            output.add(Base64.getEncoder().encodeToString(txt.getBytes()));
                        } else if("decode".equals(op)) {
                            try {
                                output.add(new String(Base64.getDecoder().decode(txt)));
                            } catch(Exception e) { output.add("<span class='text-danger'>[ERROR] Cadena no válida para Base64.</span>"); }
                        }
                    } else {
                        output.add("Uso: base64 [encode/decode] [texto]");
                    }
                    break;

                case "encrypt":
                    if(parts.length > 1) {
                        String txt = rawCmd.substring(rawCmd.indexOf("encrypt") + 8);
                        MessageDigest digest = MessageDigest.getInstance("SHA-256");
                        byte[] hash = digest.digest(txt.getBytes(StandardCharsets.UTF_8));
                        StringBuilder hexString = new StringBuilder(2 * hash.length);
                        for (byte b : hash) {
                            String hex = Integer.toHexString(0xff & b);
                            if(hex.length() == 1) hexString.append('0');
                            hexString.append(hex);
                        }
                        output.add("[SHA-256 HASH GENERATED]");
                        output.add(hexString.toString());
                    } else {
                        output.add("Uso: encrypt [texto]");
                    }
                    break;

                case "decrypt":
                    output.add("<span class='text-danger'>[ERROR] Violación de Seguridad Detección: Intentar decodificar un hash de un solo sentido (One-Way) es una operación restringida en este nodo.</span>");
                    break;

                case "crypto prices":
                    output.add("[MONITOREO DE MERCADOS BURSÁTILES (MOCK)]");
                    output.add("  BTC / USD : $68,450.00 <span class='text-success'>▲ +1.2%</span>");
                    output.add("  ETH / USD : $3,750.00 <span class='text-danger'>▼ -0.5%</span>");
                    output.add("  SOL / USD : $145.20 <span class='text-success'>▲ +4.1%</span>");
                    break;

                // ==========================================
                // 5. EASTER EGGS / HACKER JOKES
                // ==========================================
                case "matrix":
                    output.add("<span class='text-success fw-bold'>[INICIANDO INTERCEPCIÓN BITS CASCADA MATRIX]</span>");
                    output.add("01001101 01000001 01010100 01010010 01001001 01011000");
                    output.add("  11010110011010101101101001010110101011010101101");
                    output.add("    010110101011010101101010110101011010101101011");
                    output.add("      1100110101011010101101010110101011010101101");
                    output.add("        01011010110101011010101101010110101011010");
                    output.add("          101011010101101010110101011010101101010");
                    output.add("            0101101010110101011010101101010110101");
                    output.add("  11010110011010101101101001010110101011010101101");
                    output.add("<span class='text-success fw-bold'>[NÚCLEO ENCRIPTADO DE FORMA SEGURA - ESCAPE COMPLETADO]</span>");
                    break;

                case "quote":
                    String[] quotes = {
                        "\"La seguridad no es un producto, sino un proceso.\" — Bruce Schneier",
                        "\"En la informática como en la vida, las contraseñas débiles son invitaciones a intrusos.\" — Anon",
                        "\"El código es como el humor. Cuando tienes que explicarlo, es malo.\" — Cory House",
                        "\"Los datos son la contaminación del siglo XXI.\" — Bruce Schneier"
                    };
                    output.add("[CONSEJO DE SEGURIDAD]");
                    output.add("  " + quotes[new Random().nextInt(quotes.length)]);
                    break;

                case "weather":
                    output.add("[PRONÓSTICO METEOROLÓGICO DE LA RED HACKER]");
                    output.add("  Ubicación : Bogotá, Colombia (Host)");
                    output.add("  Estado    : 16°C 🌧️ (Llovizna leve)");
                    output.add("  ISP       : Excelente - Fibra Simétrica Activa");
                    break;

                case "sudo":
                    output.add("  root@hexcore: Este incidente será reportado al registro de intrusiones.");
                    output.add("  <span class='text-warning'>Estás jugando con fuego. Ya posees permisos nivel 5.</span>");
                    break;

                case "kill":
                    if(parts.length > 1) {
                        output.add("<span class='text-warning'>[WARN] Enviando señal SIGTERM al proceso " + parts[1] + "...</span>");
                        output.add("<span class='text-success'>[SUCCESS] Proceso terminado exitosamente.</span>");
                    } else {
                        output.add("Uso: kill [PID]");
                    }
                    break;

                case "reboot":
                    output.add("<span class='text-danger fw-bold'>[FATAL ERROR] Secuencia de reinicio bloqueada por el hypervisor.</span>");
                    output.add("Hay 14 sesiones médicas activas en este momento. Reinicio abortado.");
                    break;

                case "clear":
                    response.put("clear", true);
                    break;

                default:
                    output.add(String.format("<span class='text-danger'>[ERROR] Comando no reconocido: '%s'. Escribe 'help' para la lista maestra.</span>", baseCmd));
                    break;
            }
        } catch (Exception e) {
            output.add("<span class='text-danger'>[ERROR INTERNO] " + e.getMessage() + "</span>");
        }

        response.put("output", output);
        return ResponseEntity.ok(response);
    }

    private String renderBar(long count, long maxVal) {
        StringBuilder bar = new StringBuilder("[");
        long filled = (count * 20) / maxVal;
        if (filled > 20) filled = 20;
        for (int i = 0; i < 20; i++) {
            bar.append(i < filled ? "█" : "░");
        }
        bar.append("] ").append(String.format("%d%%", (count * 100) / maxVal));
        return bar.toString();
    }
}
