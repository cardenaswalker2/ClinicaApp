package com.clinicaapp.config;

import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.UsuarioRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Filtro de seguridad empresarial para control de cuentas:
 * 1. Verifica si la cuenta del usuario autenticado está suspendida (temporal o permanente).
 *    - Si es temporal y ya expiró la fecha de fin, se reactiva automáticamente.
 *    - Si sigue suspendida, se redirige a /cuenta-suspendida.
 * 2. Control de sesiones revocadas (Cierre forzoso de sesiones).
 *    - Si la sesión actual fue iniciada antes de fecha `revokedSessionsBefore`, se invalida la sesión y se redirige a /login?session_revoked.
 */
@Component
public class UserAccountControlFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(UserAccountControlFilter.class);

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getRequestURI();

        // Ignorar recursos estáticos, endpoints públicos y páginas de logout / suspensión
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/img/") ||
            path.startsWith("/webjars/") || path.startsWith("/uploads/") || path.startsWith("/video/") ||
            path.equals("/cuenta-suspendida") || path.equals("/login") || path.equals("/logout") ||
            path.equals("/error") || path.startsWith("/models/")) {
            filterChain.doFilter(request, response);
            return;
        }

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            String email = extractEmailFromAuth(auth);
            Usuario user = (email != null && !email.isBlank()) ? usuarioRepository.findByEmail(email) : null;
            if (user == null && email != null) {
                user = usuarioRepository.findByEmail(email.toLowerCase());
            }

            if (user != null) {
                HttpSession session = request.getSession(false);

                // --- 1. VERIFICACIÓN DE REVOCACIÓN FORZOSA DE SESIONES ---
                if (user.getRevokedSessionsBefore() != null && session != null) {
                    Long sessionCreationTime = session.getCreationTime();
                    LocalDateTime sessionCreationDt = LocalDateTime.ofInstant(
                            java.time.Instant.ofEpochMilli(sessionCreationTime),
                            java.time.ZoneId.systemDefault()
                    );

                    if (sessionCreationDt.isBefore(user.getRevokedSessionsBefore())) {
                        log.warn("Sesión revocada forzosamente por el administrador para usuario: {}", email);
                        session.invalidate();
                        SecurityContextHolder.clearContext();
                        if (isApiRequest(request)) {
                            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                            response.setContentType("application/json");
                            response.getWriter().write("{\"error\":\"SESSION_REVOKED\",\"message\":\"Tu sesión ha sido cerrada por el administrador por seguridad.\"}");
                            return;
                        }
                        response.sendRedirect(request.getContextPath() + "/login?session_revoked");
                        return;
                    }
                }

                // --- 2. VERIFICACIÓN DE SUSPENSIÓN (TEMPORAL O PERMANENTE) ---
                if (user.isSuspendido()) {
                    // Si es temporal, verificar si ya expiró el tiempo para auto-reactivar
                    if ("TEMPORAL".equalsIgnoreCase(user.getTipoSuspension()) && user.getFechaFinSuspension() != null) {
                        if (LocalDateTime.now().isAfter(user.getFechaFinSuspension())) {
                            // Auto-reactivar la cuenta
                            user.setSuspendido(false);
                            user.setMotivoSuspension(null);
                            user.setFechaFinSuspension(null);
                            usuarioRepository.save(user);
                            log.info("Suspensión temporal finalizada y cuenta reactivada automáticamente para: {}", email);
                            filterChain.doFilter(request, response);
                            return;
                        }
                    }

                    // No permitir a los administradores quedar bloqueados en su propio panel si no aplica
                    boolean isAdmin = auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
                    if (!isAdmin) {
                        if (isApiRequest(request)) {
                            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                            response.setContentType("application/json");
                            response.getWriter().write("{\"error\":\"ACCOUNT_SUSPENDED\",\"message\":\"Tu cuenta se encuentra suspendida.\",\"motivo\":\"" + 
                                    (user.getMotivoSuspension() != null ? user.getMotivoSuspension().replace("\"", "'") : "Sin motivo especificado") + "\"}");
                            return;
                        }
                        response.sendRedirect(request.getContextPath() + "/cuenta-suspendida");
                        return;
                    }
                }
            }
        }

        filterChain.doFilter(request, response);
    }

    private boolean isApiRequest(HttpServletRequest request) {
        String uri = request.getRequestURI();
        String accept = request.getHeader("Accept");
        String requestedWith = request.getHeader("X-Requested-With");
        return uri.startsWith("/api/") || 
               (accept != null && accept.contains("application/json")) || 
               "XMLHttpRequest".equals(requestedWith);
    }

    private String extractEmailFromAuth(Authentication auth) {
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return null;
        }
        Object principal = auth.getPrincipal();
        if (principal instanceof org.springframework.security.oauth2.core.oidc.user.OidcUser oidcUser) {
            String email = (String) oidcUser.getClaims().get("email");
            if (email != null && !email.isBlank()) return email;
        }
        if (principal instanceof org.springframework.security.oauth2.core.user.OAuth2User oAuth2User) {
            String email = (String) oAuth2User.getAttributes().get("email");
            if (email != null && !email.isBlank()) return email;
        }
        if (principal instanceof org.springframework.security.core.userdetails.UserDetails userDetails) {
            return userDetails.getUsername();
        }
        return auth.getName();
    }
}
