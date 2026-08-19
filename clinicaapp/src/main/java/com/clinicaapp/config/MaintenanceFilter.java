package com.clinicaapp.config;

import com.clinicaapp.model.ConfiguracionGlobal;
import com.clinicaapp.repository.ConfiguracionRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class MaintenanceFilter extends OncePerRequestFilter {

    @Autowired
    private ConfiguracionRepository configRepo;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getRequestURI();

        // 1. Recursos estáticos e infraestructura base (SIEMPRE PERMITIDOS)
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/img/") || 
            path.startsWith("/api/system") || path.startsWith("/api/health") || path.equals("/mantenimiento") || path.startsWith("/logout")) {
            filterChain.doFilter(request, response);
            return;
        }

        // 2. Consultar estado de mantenimiento
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS").orElse(new ConfiguracionGlobal());

        if (config.isModoMantenimiento()) {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            boolean isAdmin = auth != null && auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
            
            // Si es admin, tiene pase libre total
            if (isAdmin) {
                filterChain.doFilter(request, response);
                return;
            }

            // Comprobar si el periodo de gracia ha terminado
            boolean tiempoAgotado = true;
            if (config.getMantenimientoDesde() != null) {
                java.time.LocalDateTime limite = config.getMantenimientoDesde().plusMinutes(config.getMinutosParaCierre());
                if (java.time.LocalDateTime.now().isBefore(limite)) {
                    tiempoAgotado = false;
                }
            }

            // --- LÓGICA DE BLOQUEO ---
            
            // Si el tiempo se agotó, bloqueamos TODO excepto el panel de admin
            if (tiempoAgotado) {
                if (!path.startsWith("/admin/")) {
                    // Permitimos el login para que el admin PUEDA entrar si no ha iniciado sesión
                    if (path.equals("/login")) {
                        filterChain.doFilter(request, response);
                        return;
                    }
                    
                    response.sendRedirect("/mantenimiento");
                    return;
                }
            }
            // Si NO ha pasado el tiempo (periodo de gracia), el filtro deja pasar todo.
            // El logout lo hará el script de 'infra_monitor.html' en el navegador cuando el tiempo llegue a 0.
        }

        filterChain.doFilter(request, response);
    }
}
