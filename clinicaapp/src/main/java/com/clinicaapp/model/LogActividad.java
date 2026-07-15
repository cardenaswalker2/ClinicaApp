package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "logs_actividad")
public class LogActividad {

    @Id
    private String id;
    private LocalDateTime fecha;
    private String usuario;
    private String accion;
    private String modulo; // SEGURIDAD, CONFIGURACION, CLINICAS, CITAS, SISTEMA
    private String tipo; // INFO, SUCCESS, WARNING, ERROR
    private String detalles;
    private String ip;

    // Constructor vacío (requerido por Spring Data MongoDB)
    public LogActividad() {}

    // Constructor completo
    public LogActividad(LocalDateTime fecha, String usuario, String accion, String modulo, String tipo, String detalles, String ip) {
        this.fecha = fecha;
        this.usuario = usuario;
        this.accion = accion;
        this.modulo = modulo;
        this.tipo = tipo;
        this.detalles = detalles;
        this.ip = ip;
    }

    // --- GETTERS Y SETTERS ---

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public LocalDateTime getFecha() { return fecha; }
    public void setFecha(LocalDateTime fecha) { this.fecha = fecha; }

    public String getUsuario() { return usuario; }
    public void setUsuario(String usuario) { this.usuario = usuario; }

    public String getAccion() { return accion; }
    public void setAccion(String accion) { this.accion = accion; }

    public String getModulo() { return modulo; }
    public void setModulo(String modulo) { this.modulo = modulo; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getDetalles() { return detalles; }
    public void setDetalles(String detalles) { this.detalles = detalles; }

    public String getIp() { return ip; }
    public void setIp(String ip) { this.ip = ip; }

    // --- MÉTODOS DE COMPATIBILIDAD CON VISTAS THYMELEAF ---

    public String getTitulo() {
        return this.accion;
    }

    public String getAutor() {
        return this.usuario != null ? this.usuario : "SISTEMA";
    }

    public String getIcono() {
        if (modulo == null) return "bi-info-circle-fill";
        if ("SEGURIDAD".equalsIgnoreCase(modulo)) return "bi-shield-lock-fill";
        if ("CONFIGURACION".equalsIgnoreCase(modulo)) return "bi-cpu-fill";
        if ("CLINICAS".equalsIgnoreCase(modulo)) return "bi-hospital";
        if ("CITAS".equalsIgnoreCase(modulo)) return "bi-calendar-check-fill";
        if ("SISTEMA".equalsIgnoreCase(modulo)) return "bi-pc-display-horizontal";
        
        // Fallback por tipo de alerta
        if ("SUCCESS".equalsIgnoreCase(tipo)) return "bi-check-circle-fill";
        if ("WARNING".equalsIgnoreCase(tipo)) return "bi-exclamation-triangle-fill";
        if ("ERROR".equalsIgnoreCase(tipo)) return "bi-x-circle-fill";
        return "bi-info-circle-fill";
    }

    public String getTiempo() {
        if (fecha == null) return "Reciente";
        try {
            java.time.Duration duration = java.time.Duration.between(fecha, java.time.LocalDateTime.now());
            long seconds = duration.getSeconds();
            if (seconds < 0) seconds = 0;
            if (seconds < 60) return "Hace un momento";
            long minutes = seconds / 60;
            if (minutes < 60) return "Hace " + minutes + (minutes == 1 ? " minuto" : " minutos");
            long hours = minutes / 60;
            if (hours < 24) return "Hace " + hours + (hours == 1 ? " hora" : " horas");
            long days = hours / 24;
            return "Hace " + days + (days == 1 ? " día" : " días");
        } catch (Exception e) {
            return "Reciente";
        }
    }
}
