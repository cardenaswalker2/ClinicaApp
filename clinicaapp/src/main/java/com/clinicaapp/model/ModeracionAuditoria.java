package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "moderacion_auditoria")
public class ModeracionAuditoria {

    @Id
    private String id;
    private String superAdminId;
    private String superAdminNombre;
    private String conversacionId;
    private LocalDateTime fechaHora;
    private String ip;
    private String motivoAcceso;
    private String accionesRealizadas;

    public ModeracionAuditoria() {}

    public ModeracionAuditoria(String superAdminId, String superAdminNombre, String conversacionId, LocalDateTime fechaHora, String ip, String motivoAcceso, String accionesRealizadas) {
        this.superAdminId = superAdminId;
        this.superAdminNombre = superAdminNombre;
        this.conversacionId = conversacionId;
        this.fechaHora = fechaHora;
        this.ip = ip;
        this.motivoAcceso = motivoAcceso;
        this.accionesRealizadas = accionesRealizadas;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getSuperAdminId() { return superAdminId; }
    public void setSuperAdminId(String superAdminId) { this.superAdminId = superAdminId; }

    public String getSuperAdminNombre() { return superAdminNombre; }
    public void setSuperAdminNombre(String superAdminNombre) { this.superAdminNombre = superAdminNombre; }

    public String getConversacionId() { return conversacionId; }
    public void setConversacionId(String conversacionId) { this.conversacionId = conversacionId; }

    public LocalDateTime getFechaHora() { return fechaHora; }
    public void setFechaHora(LocalDateTime fechaHora) { this.fechaHora = fechaHora; }

    public String getIp() { return ip; }
    public void setIp(String ip) { this.ip = ip; }

    public String getMotivoAcceso() { return motivoAcceso; }
    public void setMotivoAcceso(String motivoAcceso) { this.motivoAcceso = motivoAcceso; }

    public String getAccionesRealizadas() { return accionesRealizadas; }
    public void setAccionesRealizadas(String accionesRealizadas) { this.accionesRealizadas = accionesRealizadas; }
}
