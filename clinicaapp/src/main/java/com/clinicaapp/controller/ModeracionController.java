package com.clinicaapp.controller;

import com.clinicaapp.model.MensajeChat;
import com.clinicaapp.model.ModeracionAuditoria;
import com.clinicaapp.model.ModeracionNota;
import com.clinicaapp.model.PublicacionAdopcion;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.repository.ModeracionAuditoriaRepository;
import com.clinicaapp.repository.ModeracionNotaRepository;
import com.clinicaapp.service.ComunidadPetService;
import com.clinicaapp.service.IUsuarioService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.security.Principal;
import java.time.LocalDateTime;
import java.util.*;

@Controller
@RequestMapping("/admin/moderacion/conversaciones")
public class ModeracionController {

    @Autowired
    private ComunidadPetService comunidadPetService;

    @Autowired
    private IUsuarioService usuarioService;

    @Autowired
    private ModeracionAuditoriaRepository auditoriaRepository;

    @Autowired
    private ModeracionNotaRepository notaRepository;

    private Usuario getLoggedUser(Principal principal) {
        if (principal == null) return null;
        return usuarioService.findByEmail(principal.getName()).orElse(null);
    }

    @GetMapping
    public String dashboard(Model model, Principal principal) {
        Usuario admin = getLoggedUser(principal);
        if (admin == null || admin.getRole() != Role.ROLE_ADMIN) {
            return "redirect:/login?error=noauth";
        }

        List<Map<String, Object>> conversaciones = comunidadPetService.getAllConversaciones();
        
        // Calculate mock stats
        long totalConversaciones = conversaciones.size();
        long reportadasCount = 0;
        long sospechosasCount = 0;
        
        for (Map<String, Object> c : conversaciones) {
            String msg = (String) c.get("ultimoMensaje");
            if (msg != null) {
                String lower = msg.toLowerCase();
                if (lower.contains("vender") || lower.contains("precio") || lower.contains("dinero") || lower.contains("estafa")) {
                    sospechosasCount++;
                }
            }
        }

        model.addAttribute("conversaciones", conversaciones);
        model.addAttribute("totalConversaciones", totalConversaciones);
        model.addAttribute("reportadasCount", reportadasCount);
        model.addAttribute("sospechosasCount", sospechosasCount);
        model.addAttribute("admin", admin);

        return "admin/moderacion_conversaciones";
    }

    @PostMapping("/auditar")
    public String auditarAcceso(@RequestParam String adopcionId,
                                @RequestParam String p1Id,
                                @RequestParam String p2Id,
                                @RequestParam String motivoAcceso,
                                HttpServletRequest request,
                                Principal principal,
                                RedirectAttributes redirectAttributes) {
        Usuario admin = getLoggedUser(principal);
        if (admin == null || admin.getRole() != Role.ROLE_ADMIN) {
            return "redirect:/login?error=noauth";
        }

        String ipAddress = request.getRemoteAddr();
        String convoId = adopcionId + "_" + p1Id + "_" + p2Id;

        // Register access log
        ModeracionAuditoria log = new ModeracionAuditoria(
                admin.getId(),
                admin.getNombre() + " " + admin.getApellido(),
                convoId,
                LocalDateTime.now(),
                ipAddress,
                motivoAcceso,
                "ACCESO_VISOR_CHAT"
        );
        auditoriaRepository.save(log);

        return "redirect:/admin/moderacion/conversaciones/ver/" + adopcionId + "/" + p1Id + "/" + p2Id;
    }

    @GetMapping("/ver/{adopcionId}/{p1Id}/{p2Id}")
    public String verConversacion(@PathVariable String adopcionId,
                                   @PathVariable String p1Id,
                                   @PathVariable String p2Id,
                                   Model model,
                                   Principal principal) {
        Usuario admin = getLoggedUser(principal);
        if (admin == null || admin.getRole() != Role.ROLE_ADMIN) {
            return "redirect:/login?error=noauth";
        }

        String convoId = adopcionId + "_" + p1Id + "_" + p2Id;
        
        // Verify audit log exists from this admin within the last 15 minutes
        List<ModeracionAuditoria> logs = auditoriaRepository.findByConversacionIdOrderByFechaHoraDesc(convoId);
        boolean auditado = false;
        for (ModeracionAuditoria l : logs) {
            if (l.getSuperAdminId().equals(admin.getId()) && l.getFechaHora().isAfter(LocalDateTime.now().minusMinutes(15))) {
                auditado = true;
                break;
            }
        }

        if (!auditado) {
            model.addAttribute("mensajeError", "Acceso denegado. Debe registrar un motivo de auditoría primero.");
            return "redirect:/admin/moderacion/conversaciones";
        }

        // Fetch users details
        Usuario u1 = usuarioService.findById(p1Id).orElse(null);
        Usuario u2 = usuarioService.findById(p2Id).orElse(null);
        PublicacionAdopcion pub = comunidadPetService.getById(adopcionId).orElse(null);
        
        List<MensajeChat> mensajes = comunidadPetService.getMessages(adopcionId, p1Id, p2Id);
        List<ModeracionNota> notas = notaRepository.findByConversacionIdOrderByFechaHoraDesc(convoId);

        model.addAttribute("u1", u1);
        model.addAttribute("u2", u2);
        model.addAttribute("pub", pub);
        model.addAttribute("mensajes", mensajes);
        model.addAttribute("notas", notas);
        model.addAttribute("adopcionId", adopcionId);
        model.addAttribute("p1Id", p1Id);
        model.addAttribute("p2Id", p2Id);
        model.addAttribute("convoId", convoId);
        model.addAttribute("admin", admin);

        // Sidebar listing for context
        List<Map<String, Object>> conversaciones = comunidadPetService.getAllConversaciones();
        model.addAttribute("conversaciones", conversaciones);

        return "admin/moderacion_conversaciones";
    }

    @PostMapping("/accion")
    public String realizarAccion(@RequestParam String convoId,
                                 @RequestParam String actionType,
                                 @RequestParam(required = false) String targetUserId,
                                 @RequestParam(required = false) String contenidoNota,
                                 Principal principal,
                                 RedirectAttributes redirectAttributes) {
        Usuario admin = getLoggedUser(principal);
        if (admin == null || admin.getRole() != Role.ROLE_ADMIN) {
            return "redirect:/login?error=noauth";
        }

        String[] parts = convoId.split("_");
        String adopcionId = parts[0];
        String p1Id = parts[1];
        String p2Id = parts[2];

        if ("ADD_NOTE".equals(actionType) && contenidoNota != null && !contenidoNota.trim().isEmpty()) {
            ModeracionNota nota = new ModeracionNota(
                    convoId,
                    admin.getId(),
                    admin.getNombre() + " " + admin.getApellido(),
                    contenidoNota.trim(),
                    LocalDateTime.now()
            );
            notaRepository.save(nota);
            redirectAttributes.addFlashAttribute("mensajeExito", "Nota guardada con éxito.");
        } else if ("SUSPEND_USER".equals(actionType) && targetUserId != null) {
            Optional<Usuario> opt = usuarioService.findById(targetUserId);
            if (opt.isPresent()) {
                Usuario target = opt.get();
                target.setActivo(false);
                usuarioService.save(target);
                redirectAttributes.addFlashAttribute("mensajeExito", "Usuario " + target.getNombre() + " suspendido correctamente.");
            }
        } else if ("REACTIVATE_USER".equals(actionType) && targetUserId != null) {
            Optional<Usuario> opt = usuarioService.findById(targetUserId);
            if (opt.isPresent()) {
                Usuario target = opt.get();
                target.setActivo(true);
                usuarioService.save(target);
                redirectAttributes.addFlashAttribute("mensajeExito", "Usuario " + target.getNombre() + " reactivado correctamente.");
            }
        }

        // Register audited action
        ModeracionAuditoria actionLog = new ModeracionAuditoria(
                admin.getId(),
                admin.getNombre() + " " + admin.getApellido(),
                convoId,
                LocalDateTime.now(),
                "0.0.0.0",
                "Acción de moderación ejecutada: " + actionType,
                actionType
        );
        auditoriaRepository.save(actionLog);

        return "redirect:/admin/moderacion/conversaciones/ver/" + adopcionId + "/" + p1Id + "/" + p2Id;
    }
}
