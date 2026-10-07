package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Document(collection = "mensajes_directos")
public class MensajeDirecto {

    @Id
    private String id;
    private String remitenteEmail;
    private String remitenteNombre;
    private String destinatarioId;
    private String destinatarioEmail;
    private String destinatarioNombre;
    private String asunto;
    private String contenido;
    private LocalDateTime fechaEnvio;
    private boolean leido;
    private LocalDateTime fechaLectura;
    private String tipo; // ADMIN_ALERT, DIRECT_MESSAGE, NOTIFICATION

    public MensajeDirecto() {
        this.fechaEnvio = LocalDateTime.now();
        this.leido = false;
        this.tipo = "DIRECT_MESSAGE";
    }

    public MensajeDirecto(String remitenteEmail, String remitenteNombre, String destinatarioId, 
                          String destinatarioEmail, String destinatarioNombre, String asunto, 
                          String contenido, String tipo) {
        this.remitenteEmail = remitenteEmail;
        this.remitenteNombre = remitenteNombre;
        this.destinatarioId = destinatarioId;
        this.destinatarioEmail = destinatarioEmail;
        this.destinatarioNombre = destinatarioNombre;
        this.asunto = asunto;
        this.contenido = contenido;
        this.tipo = tipo != null ? tipo : "DIRECT_MESSAGE";
        this.fechaEnvio = LocalDateTime.now();
        this.leido = false;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getRemitenteEmail() {
        return remitenteEmail;
    }

    public void setRemitenteEmail(String remitenteEmail) {
        this.remitenteEmail = remitenteEmail;
    }

    public String getRemitenteNombre() {
        return remitenteNombre;
    }

    public void setRemitenteNombre(String remitenteNombre) {
        this.remitenteNombre = remitenteNombre;
    }

    public String getDestinatarioId() {
        return destinatarioId;
    }

    public void setDestinatarioId(String destinatarioId) {
        this.destinatarioId = destinatarioId;
    }

    public String getDestinatarioEmail() {
        return destinatarioEmail;
    }

    public void setDestinatarioEmail(String destinatarioEmail) {
        this.destinatarioEmail = destinatarioEmail;
    }

    public String getDestinatarioNombre() {
        return destinatarioNombre;
    }

    public void setDestinatarioNombre(String destinatarioNombre) {
        this.destinatarioNombre = destinatarioNombre;
    }

    public String getAsunto() {
        return asunto;
    }

    public void setAsunto(String asunto) {
        this.asunto = asunto;
    }

    public String getContenido() {
        return contenido;
    }

    public void setContenido(String contenido) {
        this.contenido = contenido;
    }

    public LocalDateTime getFechaEnvio() {
        return fechaEnvio;
    }

    public void setFechaEnvio(LocalDateTime fechaEnvio) {
        this.fechaEnvio = fechaEnvio;
    }

    public boolean isLeido() {
        return leido;
    }

    public void setLeido(boolean leido) {
        this.leido = leido;
    }

    public LocalDateTime getFechaLectura() {
        return fechaLectura;
    }

    public void setFechaLectura(LocalDateTime fechaLectura) {
        this.fechaLectura = fechaLectura;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
}
