package com.clinicaapp.controller;

import com.clinicaapp.model.*;
import com.clinicaapp.repository.*;
import com.clinicaapp.service.LogActividadService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@Controller
@RequestMapping("/admin")
public class BackupController {

    @Autowired
    private UsuarioRepository usuarioRepo;

    @Autowired
    private ClinicaRepository clinicaRepo;

    @Autowired
    private CitaRepository citaRepo;

    @Autowired
    private LogActividadRepository logRepo;

    @Autowired
    private ConfiguracionRepository configRepo;

    @Autowired
    private LogActividadService logActividadService;

    @GetMapping("/respaldos")
    public String respaldos(Model model) {
        // Consultar métricas en tiempo real para el panel de diagnóstico
        long countUsuarios = usuarioRepo.count();
        long countClinicas = clinicaRepo.count();
        long countCitas = citaRepo.count();
        long countLogs = logRepo.count();

        model.addAttribute("countUsuarios", countUsuarios);
        model.addAttribute("countClinicas", countClinicas);
        model.addAttribute("countCitas", countCitas);
        model.addAttribute("countLogs", countLogs);

        // Cargar configuración global para navegación y modo mantenimiento
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new ConfiguracionGlobal());
        model.addAttribute("config", config);

        return "admin/respaldos";
    }

    @GetMapping("/respaldos/generar")
    @ResponseBody
    public ResponseEntity<byte[]> generarBackup(@RequestParam(defaultValue = "TODOS") String coleccion) {
        try {
            // Inicializar ObjectMapper y configurar soporte para Java 8 dates/time
            ObjectMapper mapper = new ObjectMapper();
            mapper.findAndRegisterModules();
            mapper.enable(com.fasterxml.jackson.databind.SerializationFeature.INDENT_OUTPUT);

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ZipOutputStream zos = new ZipOutputStream(baos);

            // 1. Exportar Colección de Usuarios
            if ("TODOS".equalsIgnoreCase(coleccion) || "USUARIOS".equalsIgnoreCase(coleccion)) {
                List<Usuario> usuarios = usuarioRepo.findAll();
                String json = mapper.writeValueAsString(usuarios);
                agregarArchivoZip(zos, "usuarios.json", json);
            }

            // 2. Exportar Colección de Clínicas
            if ("TODOS".equalsIgnoreCase(coleccion) || "CLINICAS".equalsIgnoreCase(coleccion)) {
                List<Clinica> clinicas = clinicaRepo.findAll();
                String json = mapper.writeValueAsString(clinicas);
                agregarArchivoZip(zos, "clinicas.json", json);
            }

            // 3. Exportar Colección de Citas
            if ("TODOS".equalsIgnoreCase(coleccion) || "CITAS".equalsIgnoreCase(coleccion)) {
                List<Cita> citas = citaRepo.findAll();
                String json = mapper.writeValueAsString(citas);
                agregarArchivoZip(zos, "citas.json", json);
            }

            // 4. Exportar Colección de Logs de Auditoría
            if ("TODOS".equalsIgnoreCase(coleccion) || "AUDITORIA".equalsIgnoreCase(coleccion)) {
                List<LogActividad> logs = logRepo.findAll();
                String json = mapper.writeValueAsString(logs);
                agregarArchivoZip(zos, "logs_auditoria.json", json);
            }

            // 5. Exportar Configuración Global
            if ("TODOS".equalsIgnoreCase(coleccion) || "CONFIGURACION".equalsIgnoreCase(coleccion)) {
                List<ConfiguracionGlobal> configs = configRepo.findAll();
                String json = mapper.writeValueAsString(configs);
                agregarArchivoZip(zos, "configuracion_global.json", json);
            }

            zos.finish();
            zos.close();

            byte[] zipBytes = baos.toByteArray();

            // Formatear cabeceras HTTP de descarga
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("application/zip"));
            
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String filename = "respaldo_clinicaapp_" + timestamp + ".zip";
            
            headers.setContentDisposition(ContentDisposition.builder("attachment")
                    .filename(filename)
                    .build());

            // Registrar log de auditoría del evento
            logActividadService.registrarAuto(
                "Copia de seguridad generada", 
                "SISTEMA", 
                "SUCCESS", 
                "Copia de seguridad en formato ZIP generada de forma exitosa. Filtro aplicado: " + coleccion + ". Archivo: " + filename
            );

            return new ResponseEntity<>(zipBytes, headers, HttpStatus.OK);

        } catch (Exception e) {
            // Registrar log de error de auditoría en caso de falla
            logActividadService.registrarAuto(
                "Fallo al generar copia de seguridad", 
                "SISTEMA", 
                "ERROR", 
                "Ocurrió un error crítico durante la generación del respaldo: " + e.getMessage()
            );
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    private void agregarArchivoZip(ZipOutputStream zos, String nombreArchivo, String contenido) throws IOException {
        ZipEntry entry = new ZipEntry(nombreArchivo);
        zos.putNextEntry(entry);
        zos.write(contenido.getBytes(StandardCharsets.UTF_8));
        zos.closeEntry();
    }
}
