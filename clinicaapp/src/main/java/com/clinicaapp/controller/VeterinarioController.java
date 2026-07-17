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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
        
        // Obtener citas asignadas a este veterinario
        List<Cita> todasMisCitas = citaRepository.findByClinicaId(veterinario.getClinicaId()).stream()
                .filter(c -> veterinario.getId().equals(c.getVeterinarioId()))
                .collect(Collectors.toList());

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

        model.addAttribute("citasActivas", dtosHoy);
        model.addAttribute("totalHoy", dtosHoy.size());
        model.addAttribute("totalCompletadas", citasCompletadas.size());
        model.addAttribute("veterinario", veterinario);
        model.addAttribute("clinica", clinica);

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
        Mascota mascota = mascotaService.findById(cita.getMascotaId()).orElse(null);
        Usuario cliente = usuarioRepository.findById(cita.getUsuarioId()).orElse(null);

        // Historial médico previo
        List<Visita> historial = visitaService.findByMascotaId(cita.getMascotaId());

        VisitaDTO visitaDTO = new VisitaDTO();
        visitaDTO.setCitaId(cita.getId());
        visitaDTO.setMascotaId(cita.getMascotaId());
        visitaDTO.setClinicaId(cita.getClinicaId());
        visitaDTO.setVeterinarioId(veterinario.getId());
        visitaDTO.setFechaVisita(LocalDateTime.now());

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
                                 Authentication auth,
                                 RedirectAttributes redirectAttributes) {
        Usuario veterinario = obtenerVeterinarioLogueado(auth);
        if (veterinario == null) return "redirect:/login";

        try {
            visitaDTO.setVeterinarioId(veterinario.getId());
            visitaService.save(visitaDTO);
            redirectAttributes.addFlashAttribute("mensajeExito", "¡Consulta guardada e historial actualizado exitosamente!");
        } catch (Exception e) {
            log.error("Error al registrar consulta: {}", e.getMessage());
            redirectAttributes.addFlashAttribute("mensajeError", "Error al registrar la consulta: " + e.getMessage());
        }

        return "redirect:/veterinario/dashboard";
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
