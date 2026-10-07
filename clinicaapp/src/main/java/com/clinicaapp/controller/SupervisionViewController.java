package com.clinicaapp.controller;

import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IMensajeDirectoService;
import com.clinicaapp.service.IUsuarioSupervisionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/supervision")
@PreAuthorize("hasAuthority('ROLE_ADMIN')")
public class SupervisionViewController {

    @Autowired
    private IUsuarioSupervisionService supervisionService;

    @Autowired
    private IMensajeDirectoService mensajeDirectoService;

    @Autowired
    private UsuarioRepository usuarioRepo;

    @GetMapping
    public String viewSupervision(
            @RequestParam(required = false) String usuarioId,
            @RequestParam(defaultValue = "") String q,
            Model model) {

        List<Map<String, Object>> usuarios = supervisionService.obtenerListaUsuariosSupervision(q);
        model.addAttribute("usuarios", usuarios);
        model.addAttribute("query", q);
        model.addAttribute("usuarioSeleccionadoId", usuarioId);

        if (usuarioId != null && !usuarioId.isBlank()) {
            Map<String, Object> estado = supervisionService.obtenerEstadoUsuario(usuarioId);
            model.addAttribute("estadoUsuario", estado);
            model.addAttribute("conversacion", mensajeDirectoService.obtenerConversacionConUsuario(usuarioId));
        }

        return "admin/supervision";
    }
}
