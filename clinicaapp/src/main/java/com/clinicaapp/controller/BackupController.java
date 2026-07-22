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

    @PostMapping("/respaldos/restaurar")
    public String restaurarBackup(@RequestParam("backupFile") org.springframework.web.multipart.MultipartFile file, RedirectAttributes attributes) {
        if (file.isEmpty()) {
            attributes.addFlashAttribute("mensajeError", "El archivo de respaldo está vacío o no fue seleccionado.");
            return "redirect:/admin/respaldos";
        }

        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.findAndRegisterModules();

            java.util.zip.ZipInputStream zis = new java.util.zip.ZipInputStream(file.getInputStream());
            java.util.zip.ZipEntry entry;

            int usuariosRestaurados = 0;
            int clinicasRestauradas = 0;
            int citasRestauradas = 0;
            int logsRestaurados = 0;
            int configsRestauradas = 0;

            while ((entry = zis.getNextEntry()) != null) {
                String name = entry.getName();
                ByteArrayOutputStream out = new ByteArrayOutputStream();
                byte[] buffer = new byte[1024];
                int len;
                while ((len = zis.read(buffer)) > 0) {
                    out.write(buffer, 0, len);
                }
                String content = out.toString(StandardCharsets.UTF_8.name());

                if ("usuarios.json".equals(name)) {
                    List<Usuario> list = mapper.readValue(content, mapper.getTypeFactory().constructCollectionType(List.class, Usuario.class));
                    if (!list.isEmpty()) {
                        usuarioRepo.deleteAll();
                        usuarioRepo.saveAll(list);
                        usuariosRestaurados = list.size();
                    }
                } else if ("clinicas.json".equals(name)) {
                    List<Clinica> list = mapper.readValue(content, mapper.getTypeFactory().constructCollectionType(List.class, Clinica.class));
                    if (!list.isEmpty()) {
                        clinicaRepo.deleteAll();
                        clinicaRepo.saveAll(list);
                        clinicasRestauradas = list.size();
                    }
                } else if ("citas.json".equals(name)) {
                    List<Cita> list = mapper.readValue(content, mapper.getTypeFactory().constructCollectionType(List.class, Cita.class));
                    if (!list.isEmpty()) {
                        citaRepo.deleteAll();
                        citaRepo.saveAll(list);
                        citasRestauradas = list.size();
                    }
                } else if ("logs_auditoria.json".equals(name)) {
                    List<LogActividad> list = mapper.readValue(content, mapper.getTypeFactory().constructCollectionType(List.class, LogActividad.class));
                    if (!list.isEmpty()) {
                        logRepo.deleteAll();
                        logRepo.saveAll(list);
                        logsRestaurados = list.size();
                    }
                } else if ("configuracion_global.json".equals(name)) {
                    List<ConfiguracionGlobal> list = mapper.readValue(content, mapper.getTypeFactory().constructCollectionType(List.class, ConfiguracionGlobal.class));
                    if (!list.isEmpty()) {
                        configRepo.deleteAll();
                        configRepo.saveAll(list);
                        configsRestauradas = list.size();
                    }
                }
                zis.closeEntry();
            }
            zis.close();

            String resumen = String.format("Restauración completada con éxito. Usuarios: %d, Clínicas: %d, Citas: %d, Configs: %d",
                    usuariosRestaurados, clinicasRestauradas, citasRestauradas, configsRestauradas);
            
            logActividadService.registrarAuto(
                "Restauración de copia de seguridad", 
                "SISTEMA", 
                "SUCCESS", 
                resumen
            );

            attributes.addFlashAttribute("mensajeExito", resumen);

        } catch (Exception e) {
            logActividadService.registrarAuto(
                "Fallo en restauración de copia de seguridad", 
                "SISTEMA", 
                "ERROR", 
                "Error crítico al restaurar la copia de seguridad: " + e.getMessage()
            );
            attributes.addFlashAttribute("mensajeError", "Error al procesar el archivo de respaldo: " + e.getMessage());
        }

        return "redirect:/admin/respaldos";
    }

    private void agregarArchivoZip(ZipOutputStream zos, String nombreArchivo, String contenido) throws IOException {
        ZipEntry entry = new ZipEntry(nombreArchivo);
        zos.putNextEntry(entry);
        zos.write(contenido.getBytes(StandardCharsets.UTF_8));
        zos.closeEntry();
    }
}
