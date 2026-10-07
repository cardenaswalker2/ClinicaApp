package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Document(collection = "auditoria_supervision")
public class AuditoriaSupervision {

    @Id
    private String id;
    private String adminEmail;
    private String adminNombre;
    private String usuarioAfectadoId;
    private String usuarioAfectadoEmail;
    private String usuarioAfectadoNombre;
    private String tipoAccion; // CIERRE_SESIONES, SUSPENSION_TEMPORAL, SUSPENSION_PERMANENTE, REACTIVACION, SESION_SOPORTE_INICIO, SESION_SOPORTE_FIN, RESET_PASSWORD_TRIGGER, MENSAJE_DIRECTO
    private String motivo;
    private String detalles;
    private LocalDateTime fechaHora;
    private String ip;
    private Integer duracionMinutos;

    public AuditoriaSupervision() {
        this.fechaHora = LocalDateTime.now();
    }

    public AuditoriaSupervision(String adminEmail, String adminNombre, String usuarioAfectadoId,
                                String usuarioAfectadoEmail, String usuarioAfectadoNombre,
                                String tipoAccion, String motivo, String detalles,
                                String ip, Integer duracionMinutos) {
        this.adminEmail = adminEmail;
        this.adminNombre = adminNombre;
        this.usuarioAfectadoId = usuarioAfectadoId;
        this.usuarioAfectadoEmail = usuarioAfectadoEmail;
        this.usuarioAfectadoNombre = usuarioAfectadoNombre;
        this.tipoAccion = tipoAccion;
        this.motivo = motivo;
        this.detalles = detalles;
        this.ip = ip;
        this.duracionMinutos = duracionMinutos;
        this.fechaHora = LocalDateTime.now();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getAdminEmail() { return adminEmail; }
    public void setAdminEmail(String adminEmail) { this.adminEmail = adminEmail; }
    public String getAdminNombre() { return adminNombre; }
    public void setAdminNombre(String adminNombre) { this.adminNombre = adminNombre; }
    public String getUsuarioAfectadoId() { return usuarioAfectadoId; }
    public void setUsuarioAfectadoId(String usuarioAfectadoId) { this.usuarioAfectadoId = usuarioAfectadoId; }
    public String getUsuarioAfectadoEmail() { return usuarioAfectadoEmail; }
    public void setUsuarioAfectadoEmail(String usuarioAfectadoEmail) { this.usuarioAfectadoEmail = usuarioAfectadoEmail; }
    public String getUsuarioAfectadoNombre() { return usuarioAfectadoNombre; }
    public void setUsuarioAfectadoNombre(String usuarioAfectadoNombre) { this.usuarioAfectadoNombre = usuarioAfectadoNombre; }
    public String getTipoAccion() { return tipoAccion; }
    public void setTipoAccion(String tipoAccion) { this.tipoAccion = tipoAccion; }
    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }
    public String getDetalles() { return detalles; }
    public void setDetalles(String detalles) { this.detalles = detalles; }
    public LocalDateTime getFechaHora() { return fechaHora; }
    public void setFechaHora(LocalDateTime fechaHora) { this.fechaHora = fechaHora; }
    public String getIp() { return ip; }
    public void setIp(String ip) { this.ip = ip; }
    public Integer getDuracionMinutos() { return duracionMinutos; }
    public void setDuracionMinutos(Integer duracionMinutos) { this.duracionMinutos = duracionMinutos; }
}
