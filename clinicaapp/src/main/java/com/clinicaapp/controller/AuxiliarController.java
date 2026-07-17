package com.clinicaapp.controller;

import com.clinicaapp.model.Mascota;
import com.clinicaapp.model.Clinica;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.MascotaRepository;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.repository.ClinicaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/auxiliar")
public class AuxiliarController {

    private static final Logger log = LoggerFactory.getLogger(AuxiliarController.class);

    @Autowired
    private MascotaRepository mascotaRepository;
    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private ClinicaRepository clinicaRepository;

    private Usuario obtenerAuxiliarLogueado(Authentication auth) {
        if (auth == null) return null;
        return usuarioRepository.findByEmail(auth.getName());
    }

    private Clinica obtenerClinicaLogueada(Usuario auxiliar) {
        if (auxiliar == null || auxiliar.getClinicaId() == null) return null;
        return clinicaRepository.findById(auxiliar.getClinicaId()).orElse(null);
    }

    @GetMapping("/dashboard")
    public String dashboard(Authentication auth, Model model) {
        Usuario auxiliar = obtenerAuxiliarLogueado(auth);
        if (auxiliar == null) return "redirect:/login";

        Clinica clinica = obtenerClinicaLogueada(auxiliar);

        // Obtener mascotas de la clínica
        List<Mascota> pacientes = mascotaRepository.findByClinicaId(auxiliar.getClinicaId());

        // Filtrar hospitalizados
        List<Mascota> hospitalizados = pacientes.stream()
                .filter(m -> "Hospitalizado".equalsIgnoreCase(m.getEstadoHospitalizacion()))
                .collect(Collectors.toList());

        // Filtrar de alta u otros
        List<Mascota> consultaGeneral = pacientes.stream()
                .filter(m -> !"Hospitalizado".equalsIgnoreCase(m.getEstadoHospitalizacion()))
                .collect(Collectors.toList());

        model.addAttribute("hospitalizados", hospitalizados);
        model.addAttribute("consultaGeneral", consultaGeneral);
        model.addAttribute("auxiliar", auxiliar);
        model.addAttribute("clinica", clinica);

        return "auxiliar/dashboard_auxiliar";
    }

    @GetMapping("/mascotas/{id}/signos-vitales")
    public String verSignosVitales(@PathVariable String id, Authentication auth, Model model, RedirectAttributes redirectAttributes) {
        Usuario auxiliar = obtenerAuxiliarLogueado(auth);
        if (auxiliar == null) return "redirect:/login";

        Optional<Mascota> mascotaOpt = mascotaRepository.findById(id);
        if (mascotaOpt.isEmpty() || !auxiliar.getClinicaId().equals(mascotaOpt.get().getClinicaId())) {
            redirectAttributes.addFlashAttribute("mensajeError", "No autorizado para ver este paciente.");
            return "redirect:/auxiliar/dashboard";
        }

        model.addAttribute("mascota", mascotaOpt.get());
        model.addAttribute("auxiliar", auxiliar);
        model.addAttribute("clinica", obtenerClinicaLogueada(auxiliar));

        return "auxiliar/form_signos_vitales";
    }

    @PostMapping("/mascotas/guardar-signos-vitales")
    public String guardarSignosVitales(@RequestParam("id") String id,
                                       @RequestParam("estadoHospitalizacion") String estadoHospitalizacion,
                                       @RequestParam("temperatura") Double temperatura,
                                       @RequestParam("frecuenciaCardiaca") Integer frecuenciaCardiaca,
                                       @RequestParam(value = "observacionesAuxiliar", required = false) String observacionesAuxiliar,
                                       Authentication auth,
                                       RedirectAttributes redirectAttributes) {
        Usuario auxiliar = obtenerAuxiliarLogueado(auth);
        if (auxiliar == null) return "redirect:/login";

        try {
            Optional<Mascota> mascotaOpt = mascotaRepository.findById(id);
            if (mascotaOpt.isPresent() && auxiliar.getClinicaId().equals(mascotaOpt.get().getClinicaId())) {
                Mascota m = mascotaOpt.get();
                m.setEstadoHospitalizacion(estadoHospitalizacion);
                m.setTemperatura(temperatura);
                m.setFrecuenciaCardiaca(frecuenciaCardiaca);
                m.setObservacionesAuxiliar(observacionesAuxiliar);
                mascotaRepository.save(m);
                redirectAttributes.addFlashAttribute("mensajeExito", "¡Signos vitales y estado del paciente actualizados!");
            } else {
                redirectAttributes.addFlashAttribute("mensajeError", "No autorizado para modificar este paciente.");
            }
        } catch (Exception e) {
            log.error("Error al guardar signos vitales: {}", e.getMessage());
            redirectAttributes.addFlashAttribute("mensajeError", "Error al actualizar signos vitales.");
        }

        return "redirect:/auxiliar/dashboard";
    }
}
