package com.clinicaapp.config;

import com.clinicaapp.model.enums.Role;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Collection;

@Component
public class CustomAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

    @Autowired
    private com.clinicaapp.repository.ConfiguracionRepository configRepo;

    @Autowired
    private com.clinicaapp.service.LogActividadService logActividadService;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {
        if (response.isCommitted()) return;

        // Registrar log de inicio de sesión exitoso
        try {
            String rol = authentication.getAuthorities().toString();
            logActividadService.registrar(
                authentication.getName(),
                "Inicio de sesión exitoso",
                "SEGURIDAD",
                "SUCCESS",
                "Usuario autenticado por formulario con roles: " + rol,
                request.getRemoteAddr()
            );
        } catch (Exception e) {
            // Ignorar
        }

        // Comprobar modo mantenimiento
        com.clinicaapp.model.ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS").orElse(new com.clinicaapp.model.ConfiguracionGlobal());
        boolean isAdmin = authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        if (config.isModoMantenimiento() && !isAdmin) {
            response.sendRedirect("/logout?maintenance");
            return;
        }

        // ESTE HANDLER ES PARA LOGIN CON FORMULARIO
        Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();

        for (GrantedAuthority grantedAuthority : authorities) {
            String authorityName = grantedAuthority.getAuthority();

            // 1. Redirección para ADMINISTRADOR
            if (authorityName.equals(Role.ROLE_ADMIN.name())) {
                response.sendRedirect("/admin/dashboard");
                return;
            } 
            
            // 2. Redirección para RECEPCIONISTA
            else if (authorityName.equals(Role.ROLE_RECEPCIONISTA.name())) {
                response.sendRedirect("/recepcion/dashboard");
                return;
            } 
            
            // 3. NUEVA: Redirección para CLÍNICA
            else if (authorityName.equals(Role.ROLE_CLINICA.name())) {
                response.sendRedirect("/clinica/dashboard");
                return;
            } 
            
            // 4. Redirección para USUARIO / CLIENTE
            else if (authorityName.equals(Role.ROLE_USER.name())) {
                response.sendRedirect("/usuario/dashboard");
                return;
            }
        }
        
        // Redirección por defecto si no coincide ningún rol específico
        response.sendRedirect("/");
    }
}