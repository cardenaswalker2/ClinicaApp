package com.clinicaapp.controller;

import com.clinicaapp.dto.CitaDisplayDTO;
import com.clinicaapp.dto.VisitaDTO;
import com.clinicaapp.model.*;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.repository.ClinicaRepository;
import com.clinicaapp.repository.CitaRepository;
import com.clinicaapp.repository.VisitaRepository;
import com.clinicaapp.service.ICitaService;
import com.clinicaapp.service.IMascotaService;
import com.clinicaapp.service.IVisitaService;
import com.clinicaapp.service.IServicioService;
import com.clinicaapp.service.IPdfService;
import com.clinicaapp.service.IEmailService;
import com.clinicaapp.service.INotificacionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/veterinario")
public class VeterinarioController {

    private static final Logger log = LoggerFactory.getLogger(VeterinarioController.class);

    @Autowired
    private ICitaService citaService;
    @Autowired
    private CitaRepository citaRepository;
    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private ClinicaRepository clinicaRepository;
    @Autowired
    private IMascotaService mascotaService;
    @Autowired
    private IVisitaService visitaService;
    @Autowired
    private VisitaRepository visitaRepository;
    @Autowired
    private IServicioService servicioService;
    @Autowired
    private com.clinicaapp.repository.AnuncioGlobalRepository anuncioGlobalRepository;
    @Autowired
    private IPdfService pdfService;
    @Autowired
    private IEmailService emailService;
    @Autowired
    private INotificacionService notificacionService;

    private Usuario obtenerVeterinarioLogueado(Authentication auth) {
        if (auth == null) return null;
        return usuarioRepository.findByEmail(auth.getName());
    }

    private Clinica obtenerClinicaLogueada(Usuario veterinario) {
        if (veterinario == null || veterinario.getClinicaId() == null) return null;
        return clinicaRepository.findById(veterinario.getClinicaId()).orElse(null);
    }

    @GetMapping("/dashboard")
    public String dashboard(Authentication auth, Model model) {
        Usuario veterinario = obtenerVeterinarioLogueado(auth);
        if (veterinario == null) return "redirect:/login";

        Clinica clinica = obtenerClinicaLogueada(veterinario);
        if (clinica == null) {
            clinica = new Clinica();
            clinica.setNombre("Clínica Veterinaria Mascotas");
        }
        
        // Obtener citas asignadas a este veterinario
        List<Cita> todasMisCitas = new ArrayList<>();
        if (veterinario.getClinicaId() != null) {
            todasMisCitas = citaRepository.findByClinicaId(veterinario.getClinicaId()).stream()
                    .filter(c -> veterinario.getId().equals(c.getVeterinarioId()))
                    .collect(Collectors.toList());
        }

        LocalDate hoy = LocalDate.now();

        // Citas de hoy pendientes
        List<Cita> citasDeHoy = todasMisCitas.stream()
                .filter(c -> c.getFechaHora() != null && c.getFechaHora().toLocalDate().equals(hoy))
                .filter(c -> "Confirmada".equalsIgnoreCase(c.getEstado()) || "En Espera".equalsIgnoreCase(c.getEstado()) || "Pendiente".equalsIgnoreCase(c.getEstado()))
                .collect(Collectors.toList());

        List<CitaDisplayDTO> dtosHoy = convertToDisplayDTO(citasDeHoy);

        // Citas completadas por el veterinario
        List<Cita> citasCompletadas = todasMisCitas.stream()
                .filter(c -> "Completada".equalsIgnoreCase(c.getEstado()))
                .collect(Collectors.toList());

        String fechaHoy = java.time.format.DateTimeFormatter.ofPattern("dd 'de' MMMM 'de' yyyy", new java.util.Locale("es", "ES")).format(java.time.LocalDate.now());
        model.addAttribute("fechaHoy", fechaHoy);

        model.addAttribute("citasActivas", dtosHoy);
        model.addAttribute("totalHoy", dtosHoy.size());
        model.addAttribute("totalCompletadas", citasCompletadas.size());
        model.addAttribute("veterinario", veterinario);
        model.addAttribute("clinica", clinica);
        model.addAttribute("anunciosGlobales", anuncioGlobalRepository.findByActivoTrue());

        return "veterinario/dashboard_veterinario";
    }

    @GetMapping("/citas/{id}/atender")
    public String atenderCita(@PathVariable String id, Authentication auth, Model model, RedirectAttributes redirectAttributes) {
        Usuario veterinario = obtenerVeterinarioLogueado(auth);
        if (veterinario == null) return "redirect:/login";

        Optional<Cita> citaOpt = citaService.findById(id);
        if (citaOpt.isEmpty() || !veterinario.getId().equals(citaOpt.get().getVeterinarioId())) {
            redirectAttributes.addFlashAttribute("mensajeError", "No tienes permiso para atender esta cita.");
            return "redirect:/veterinario/dashboard";
        }

        Cita cita = citaOpt.get();
        
        // Cargar visita existente si es un borrador
        Optional<Visita> visitaExistente = visitaRepository.findByCitaId(cita.getId());
        if (visitaExistente.isPresent() && visitaExistente.get().isBloqueada()) {
            redirectAttributes.addFlashAttribute("mensajeError", "Esta consulta ya ha sido cerrada definitivamente y no puede ser modificada.");
            return "redirect:/veterinario/dashboard";
        }

        if ("En Espera".equalsIgnoreCase(cita.getEstado()) || "Confirmada".equalsIgnoreCase(cita.getEstado()) || "Pendiente".equalsIgnoreCase(cita.getEstado())) {
            cita.setEstado("En Consulta");
            citaRepository.save(cita);
        }
        Mascota mascota = mascotaService.findById(cita.getMascotaId()).orElse(null);
        Usuario cliente = usuarioRepository.findById(cita.getUsuarioId()).orElse(null);
        List<Visita> historial = visitaService.findByMascotaId(cita.getMascotaId());

        VisitaDTO visitaDTO = new VisitaDTO();
        if (visitaExistente.isPresent()) {
            BeanUtils.copyProperties(visitaExistente.get(), visitaDTO);
        } else {
            visitaDTO.setCitaId(cita.getId());
            visitaDTO.setMascotaId(cita.getMascotaId());
            visitaDTO.setClinicaId(cita.getClinicaId());
            visitaDTO.setVeterinarioId(veterinario.getId());
            visitaDTO.setFechaVisita(LocalDateTime.now());
        }

        model.addAttribute("cita", cita);
        model.addAttribute("mascota", mascota);
        model.addAttribute("cliente", cliente);
        model.addAttribute("historial", historial);
        model.addAttribute("visitaDTO", visitaDTO);
        model.addAttribute("veterinario", veterinario);
        model.addAttribute("clinica", obtenerClinicaLogueada(veterinario));

        return "veterinario/form_atender_cita";
    }

    @GetMapping("/citas/{citaId}/editar-consulta/{visitaId}")
    public String editarConsulta(@PathVariable String citaId, @PathVariable String visitaId, Authentication auth, Model model, RedirectAttributes redirectAttributes) {
        Usuario veterinario = obtenerVeterinarioLogueado(auth);
        if (veterinario == null) return "redirect:/login";

        Optional<Cita> citaOpt = citaService.findById(citaId);
        Optional<Visita> visitaOpt = visitaRepository.findById(visitaId);
        if (citaOpt.isEmpty() || visitaOpt.isEmpty() || !veterinario.getId().equals(citaOpt.get().getVeterinarioId())) {
            redirectAttributes.addFlashAttribute("mensajeError", "No tienes permiso para editar esta consulta.");
            return "redirect:/veterinario/dashboard";
        }

        Visita visita = visitaOpt.get();
        if (visita.isBloqueada()) {
            redirectAttributes.addFlashAttribute("mensajeError", "Esta consulta ya ha sido cerrada definitivamente y no puede ser modificada.");
            return "redirect:/veterinario/dashboard";
        }

        Cita cita = citaOpt.get();
        Mascota mascota = mascotaService.findById(cita.getMascotaId()).orElse(null);
        Usuario cliente = usuarioRepository.findById(cita.getUsuarioId()).orElse(null);
        List<Visita> historial = visitaService.findByMascotaId(cita.getMascotaId());

        VisitaDTO visitaDTO = new VisitaDTO();
        BeanUtils.copyProperties(visita, visitaDTO);

        model.addAttribute("cita", cita);
        model.addAttribute("mascota", mascota);
        model.addAttribute("cliente", cliente);
        model.addAttribute("historial", historial);
        model.addAttribute("visitaDTO", visitaDTO);
        model.addAttribute("veterinario", veterinario);
        model.addAttribute("clinica", obtenerClinicaLogueada(veterinario));

        return "veterinario/form_atender_cita";
    }

    @PostMapping("/citas/guardar-consulta")
    public String guardarConsulta(@ModelAttribute("visitaDTO") VisitaDTO visitaDTO,
                                 @RequestParam(value = "finalizar", defaultValue = "false") boolean finalizar,
                                 @RequestParam(value = "adjuntos", required = false) org.springframework.web.multipart.MultipartFile[] adjuntos,
                                 Authentication auth,
                                 RedirectAttributes redirectAttributes) {
        Usuario veterinario = obtenerVeterinarioLogueado(auth);
        if (veterinario == null) return "redirect:/login";

        try {
            List<String> adjuntosUrls = new ArrayList<>();
            if (visitaDTO.getId() != null && !visitaDTO.getId().isEmpty()) {
                visitaRepository.findById(visitaDTO.getId()).ifPresent(v -> {
                    if (v.getAdjuntosUrls() != null) {
                        adjuntosUrls.addAll(v.getAdjuntosUrls());
                    }
                });
            }
            if (adjuntos != null) {
                for (org.springframework.web.multipart.MultipartFile file : adjuntos) {
                    if (!file.isEmpty()) {
                        String url = guardarArchivo(file);
                        if (url != null) adjuntosUrls.add(url);
                    }
                }
            }
            visitaDTO.setAdjuntosUrls(adjuntosUrls);
            visitaDTO.setVeterinarioId(veterinario.getId());
            
            if (finalizar) {
                visitaDTO.setBloqueada(true);
            }

            Visita visitaSaved = visitaService.save(visitaDTO);

            if (finalizar) {
                Optional<Cita> citaOpt = citaRepository.findById(visitaDTO.getCitaId());
                if (citaOpt.isPresent()) {
                    Cita cita = citaOpt.get();
                    cita.setEstado("Consulta Finalizada");
                    citaRepository.save(cita);
                }

                try {
                    Clinica clinica = obtenerClinicaLogueada(veterinario);
                    Mascota mascota = mascotaService.findById(visitaDTO.getMascotaId()).orElse(null);
                    Usuario dueno = usuarioRepository.findById(mascota != null ? mascota.getPropietarioId() : "").orElse(null);

                    if (clinica != null && mascota != null && dueno != null) {
                        notificacionService.crearNotificacion(
                            dueno.getId(), 
                            "¡Consulta Médica Finalizada!", 
                            "Se ha completado la atención de " + mascota.getNombre() + ".", 
                            "/usuario/historial/" + mascota.getId()
                        );

                        List<Usuario> admins = usuarioRepository.findByClinicaIdAndRole(clinica.getId(), Role.ROLE_CLINICA);
                        for (Usuario admin : admins) {
                            notificacionService.crearNotificacion(
                                admin.getId(),
                                "Consulta Finalizada",
                                "La consulta de " + mascota.getNombre() + " fue finalizada por el Dr. " + veterinario.getNombre() + ".",
                                "/clinica/dashboard"
                            );
                        }

                        java.util.Map<String, Object> data = new java.util.HashMap<>();
                        data.put("visita", visitaSaved);
                        data.put("clinica", clinica);
                        data.put("mascota", mascota);
                        data.put("dueno", dueno);
                        data.put("veterinario", veterinario);

                        java.io.ByteArrayInputStream bis = pdfService.generatePdfFromTemplate("clinica/pdf_receta", data);
                        byte[] pdfBytes = bis.readAllBytes();

                        String subject = "🩺 Historial de Consulta: " + mascota.getNombre() + " - " + clinica.getNombre();
                        String htmlBody = String.format(
                                """
                                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 10px; background-color: #ffffff;">
                                    <div style="background-color: #4f46e5; color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0;">
                                        <h2>Resumen de Consulta Médica</h2>
                                        <p>%s</p>
                                    </div>
                                    <div style="padding: 20px; color: #334155; line-height: 1.6;">
                                        <p>Hola <strong>%s</strong>,</p>
                                        <p>Queremos informarte que la consulta médica de tu mascota <strong>%s</strong> ha sido finalizada con éxito por el <strong>Dr. %s</strong>.</p>
                                        <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 15px; margin: 20px 0;">
                                            <p style="margin: 5px 0;"><strong>Diagnóstico Principal:</strong> %s</p>
                                            <p style="margin: 5px 0;"><strong>Tratamiento recomendado:</strong> %s</p>
                                        </div>
                                        <p>Adjunto a este correo encontrarás el reporte médico oficial en formato PDF con la receta, constantes vitales y observaciones detalladas.</p>
                                    </div>
                                    <div style="text-align: center; font-size: 12px; color: #94a3b8; border-top: 1px solid #e2e8f0; padding-top: 15px; margin-top: 20px;">
                                        Este es un correo automático generado por ClínicaApp. Consérvalo para el historial de tu mascota.
                                    </div>
                                </div>
                                """,
                                clinica.getNombre(),
                                dueno.getNombre(),
                                mascota.getNombre(),
                                veterinario.getNombre() + " " + (veterinario.getApellido() != null ? veterinario.getApellido() : ""),
                                visitaSaved.getDiagnosticoPrincipal() != null ? visitaSaved.getDiagnosticoPrincipal() : (visitaSaved.getDiagnostico() != null ? visitaSaved.getDiagnostico() : "Consulta General"),
                                visitaSaved.getTratamiento()
                        );

                        emailService.sendMessageWithAttachment(
                            dueno.getEmail(),
                            subject,
                            htmlBody,
                            "Reporte_Consulta_" + mascota.getNombre() + ".pdf",
                            pdfBytes
                        );
                        log.info("✅ Reporte enviado a: {}", dueno.getEmail());
                    }
                } catch (Exception e) {
                    log.error("❌ Error al procesar envío de reporte: {}", e.getMessage(), e);
                }

                redirectAttributes.addFlashAttribute("mensajeExito", "¡Consulta finalizada y cerrada definitivamente. Registro clínico bloqueado!");
            } else {
                redirectAttributes.addFlashAttribute("mensajeExito", "¡Borrador guardado exitosamente! Puedes seguir editando el registro clínico.");
            }
        } catch (Exception e) {
            log.error("Error al registrar consulta: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("mensajeError", "Error al registrar la consulta: " + e.getMessage());
        }

        return "redirect:/veterinario/dashboard";
    }

    private String guardarArchivo(org.springframework.web.multipart.MultipartFile file) {
        if (file == null || file.isEmpty()) return null;
        try {
            String uploadDir = "uploads";
            java.nio.file.Path uploadPath = java.nio.file.Paths.get(uploadDir);
            if (!java.nio.file.Files.exists(uploadPath)) {
                java.nio.file.Files.createDirectories(uploadPath);
            }
            String fileName = java.util.UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
            java.nio.file.Path filePath = uploadPath.resolve(fileName);
            java.nio.file.Files.copy(file.getInputStream(), filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            return "/uploads/" + fileName;
        } catch (java.io.IOException e) {
            log.error("Error al guardar archivo: {}", e.getMessage());
            return null;
        }
    }

    private List<CitaDisplayDTO> convertToDisplayDTO(List<Cita> citas) {
        return citas.stream().map(cita -> {
            Usuario u = usuarioRepository.findById(cita.getUsuarioId()).orElse(null);
            Clinica c = clinicaRepository.findById(cita.getClinicaId()).orElse(null);
            Mascota m = mascotaService.findById(cita.getMascotaId()).orElse(null);

            List<Servicio> servicios = new ArrayList<>();
            if (cita.getServiciosIds() != null) {
                for (String sId : cita.getServiciosIds()) {
                    servicioService.findById(sId).ifPresent(servicios::add);
                }
            }
            return new CitaDisplayDTO(cita, u, c, m, servicios);
        }).collect(Collectors.toList());
    }
}
