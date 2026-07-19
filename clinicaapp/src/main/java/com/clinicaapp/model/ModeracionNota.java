package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "moderacion_notas")
public class ModeracionNota {

    @Id
    private String id;
    private String conversacionId;
    private String adminId;
    private String adminNombre;
    private String contenido;
    private LocalDateTime fechaHora;

    public ModeracionNota() {}

    public ModeracionNota(String conversacionId, String adminId, String adminNombre, String contenido, LocalDateTime fechaHora) {
        this.conversacionId = conversacionId;
        this.adminId = adminId;
        this.adminNombre = adminNombre;
        this.contenido = contenido;
        this.fechaHora = fechaHora;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getConversacionId() { return conversacionId; }
    public void setConversacionId(String conversacionId) { this.conversacionId = conversacionId; }

    public String getAdminId() { return adminId; }
    public void setAdminId(String adminId) { this.adminId = adminId; }

    public String getAdminNombre() { return adminNombre; }
    public void setAdminNombre(String adminNombre) { this.adminNombre = adminNombre; }

    public String getContenido() { return contenido; }
    public void setContenido(String contenido) { this.contenido = contenido; }

    public LocalDateTime getFechaHora() { return fechaHora; }
    public void setFechaHora(LocalDateTime fechaHora) { this.fechaHora = fechaHora; }
}
