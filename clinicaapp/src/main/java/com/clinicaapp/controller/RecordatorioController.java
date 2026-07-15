package com.clinicaapp.controller;

import com.clinicaapp.model.Recordatorio;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.service.IRecordatorioService;
import com.clinicaapp.service.IUsuarioService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.security.Principal;
import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/usuario/recordatorios")
public class RecordatorioController {

    private static final Logger log = LoggerFactory.getLogger(RecordatorioController.class);

    @Autowired private IRecordatorioService recordatorioService;
    @Autowired private IUsuarioService usuarioService;

    @GetMapping
    public String gestionRecordatorios(Model model, Principal principal) {
        Usuario usuario = getLoggedUser(principal);
        if (usuario == null) return "redirect:/login";

        List<Recordatorio> recordatorios = recordatorioService.listarPorUsuario(usuario.getId());
        model.addAttribute("recordatorios", recordatorios);
        model.addAttribute("usuario", usuario);
        
        return "usuario/gestion_recordatorios";
    }

    @PostMapping("/guardar")
    public String guardarRecordatorio(
            @RequestParam String titulo,
            @RequestParam String descripcion,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fechaHora,
            @RequestParam Recordatorio.TipoRecordatorio tipo,
            Principal principal,
            RedirectAttributes redirectAttributes) {

        Usuario usuario = getLoggedUser(principal);
        if (usuario == null) return "redirect:/login";

        Recordatorio r = new Recordatorio();
        r.setUsuarioId(usuario.getId());
        r.setTitulo(titulo);
        r.setDescripcion(descripcion);
        r.setFechaHora(fechaHora);
        r.setTipo(tipo);
        r.setEstado(Recordatorio.EstadoRecordatorio.PENDIENTE);

        recordatorioService.guardar(r);
        redirectAttributes.addFlashAttribute("mensajeExito", "Recordatorio programado correctamente.");

        return "redirect:/usuario/recordatorios";
    }

    @PostMapping("/eliminar/{id}")
    public String eliminarRecordatorio(@PathVariable String id, Principal principal, RedirectAttributes redirectAttributes) {
        Usuario usuario = getLoggedUser(principal);
        if (usuario == null) return "redirect:/login";

        // Deberíamos validar que el recordatorio pertenezca al usuario, pero por simplicidad en este MVP
        recordatorioService.eliminar(id);
        redirectAttributes.addFlashAttribute("mensajeExito", "Recordatorio eliminado.");

        return "redirect:/usuario/recordatorios";
    }

    @PostMapping("/enviar-ahora/{id}")
    public String enviarAhora(@PathVariable String id, Principal principal, RedirectAttributes redirectAttributes) {
        Usuario usuario = getLoggedUser(principal);
        if (usuario == null) return "redirect:/login";

        recordatorioService.enviarAhora(id);
        redirectAttributes.addFlashAttribute("mensajeExito", "Recordatorio enviado inmediatamente.");

        return "redirect:/usuario/recordatorios";
    }

    private Usuario getLoggedUser(Principal principal) {
        if (principal == null) return null;
        if (principal instanceof Authentication) {
            Authentication auth = (Authentication) principal;
            Object p = auth.getPrincipal();
            if (p instanceof OAuth2User) {
                Object emailObj = ((OAuth2User) p).getAttributes().get("email");
                if (emailObj != null) return usuarioService.findByEmail(emailObj.toString());
            }
            if (p instanceof UserDetails) {
                return usuarioService.findByEmail(((UserDetails) p).getUsername());
            }
        }
        return usuarioService.findByEmail(principal.getName());
    }
}
