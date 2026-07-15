package com.clinicaapp.service.impl;

import com.clinicaapp.model.LogActividad;
import com.clinicaapp.repository.LogActividadRepository;
import com.clinicaapp.service.LogActividadService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class LogActividadServiceImpl implements LogActividadService {

    @Autowired
    private LogActividadRepository logRepo;

    @Override
    public void registrar(String usuario, String accion, String modulo, String tipo, String detalles, String ip) {
        LogActividad log = new LogActividad(
                LocalDateTime.now(),
                usuario != null ? usuario : "SISTEMA",
                accion,
                modulo != null ? modulo.toUpperCase() : "SISTEMA",
                tipo != null ? tipo.toUpperCase() : "INFO",
                detalles,
                ip != null ? ip : "127.0.0.1"
        );
        logRepo.save(log);
    }

    @Override
    public void registrarAuto(String accion, String modulo, String tipo, String detalles) {
        String usuario = "SISTEMA";
        String ip = "127.0.0.1";

        // 1. Obtener usuario autenticado desde el contexto de seguridad
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
                usuario = auth.getName();
            } else {
                usuario = "ANÓNIMO";
            }
        } catch (Exception e) {
            // Ignorar fuera de un contexto de seguridad activo
        }

        // 2. Obtener dirección IP y request desde el RequestContextHolder
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                if (request != null) {
                    ip = obtenerIpCliente(request);
                }
            }
        } catch (Exception e) {
            // Ignorar si no se llama dentro de un hilo de petición HTTP activa
        }

        registrar(usuario, accion, modulo, tipo, detalles, ip);
    }

    @Override
    public List<LogActividad> obtenerUltimos5() {
        return logRepo.findTop5ByOrderByFechaDesc();
    }

    @Override
    public Page<LogActividad> buscarLogsPaginados(String query, String modulo, String tipo, int pagina, int tamano) {
        Pageable pageable = PageRequest.of(pagina, tamano, Sort.by("fecha").descending());
        
        // Limpiar parámetros para la expresión regular
        String textQuery = query != null ? query.trim() : "";
        String moduloPattern = (modulo != null && !modulo.isEmpty() && !"TODOS".equalsIgnoreCase(modulo)) ? modulo : "";
        String tipoPattern = (tipo != null && !tipo.isEmpty() && !"TODOS".equalsIgnoreCase(tipo)) ? tipo : "";
        
        return logRepo.searchLogs(textQuery, moduloPattern, tipoPattern, pageable);
    }

    @Override
    public void limpiarLogs() {
        String ip = "127.0.0.1";
        String usuario = "SISTEMA";
        
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                ip = obtenerIpCliente(attributes.getRequest());
            }
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.isAuthenticated()) {
                usuario = auth.getName();
            }
        } catch (Exception e) {
            // Ignorar
        }
        
        logRepo.deleteAll();
        
        // Registrar log inmutable de limpieza
        registrar(usuario, "Historial de logs de auditoría vaciado por el administrador", "SISTEMA", "WARNING", "Vaciado completo de la colección logs_actividad en MongoDB.", ip);
    }

    // Método utilitario para extraer la dirección IP real del cliente
    private String obtenerIpCliente(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // En IPv6 local, simplificar a 127.0.0.1 para legibilidad
        if ("0:0:0:0:0:0:0:1".equals(ip)) {
            ip = "127.0.0.1";
        }
        return ip;
    }
}
