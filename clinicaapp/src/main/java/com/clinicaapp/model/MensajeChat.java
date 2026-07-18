package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Document(collection = "mensajes_chat")
public class MensajeChat {

    @Id
    private String id;
    
    private String adopcionId;
    private String emisorId;
    private String emisorNombre;
    private String receptorId;
    private String receptorNombre;
    private String contenido;
    private LocalDateTime fechaHora;
    private boolean leido;
    
    private String tipo = "TEXTO"; // TEXTO, IMAGEN, DOCUMENTO, ENCUENTRO
    private String attachmentUrl;
    private String attachmentNombre;
    private boolean fijado;
    private java.util.Map<String, String> reacciones = new java.util.HashMap<>();
    
    private String lugarEncuentro;
    private String fechaHoraEncuentro;
    private String estadoEncuentro; // PROPUESTO, CONFIRMADO, CANCELADO

    public MensajeChat() {
        this.fechaHora = LocalDateTime.now();
        this.leido = false;
        this.tipo = "TEXTO";
        this.fijado = false;
        this.reacciones = new java.util.HashMap<>();
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getAdopcionId() {
        return adopcionId;
    }

    public void setAdopcionId(String adopcionId) {
        this.adopcionId = adopcionId;
    }

    public String getEmisorId() {
        return emisorId;
    }

    public void setEmisorId(String emisorId) {
        this.emisorId = emisorId;
    }

    public String getEmisorNombre() {
        return emisorNombre;
    }

    public void setEmisorNombre(String emisorNombre) {
        this.emisorNombre = emisorNombre;
    }

    public String getReceptorId() {
        return receptorId;
    }

    public void setReceptorId(String receptorId) {
        this.receptorId = receptorId;
    }

    public String getReceptorNombre() {
        return receptorNombre;
    }

    public void setReceptorNombre(String receptorNombre) {
        this.receptorNombre = receptorNombre;
    }

    public String getContenido() {
        return contenido;
    }

    public void setContenido(String contenido) {
        this.contenido = contenido;
    }

    public LocalDateTime getFechaHora() {
        return fechaHora;
    }

    public void setFechaHora(LocalDateTime fechaHora) {
        this.fechaHora = fechaHora;
    }

    public boolean isLeido() {
        return leido;
    }

    public void setLeido(boolean leido) {
        this.leido = leido;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getAttachmentUrl() {
        return attachmentUrl;
    }

    public void setAttachmentUrl(String attachmentUrl) {
        this.attachmentUrl = attachmentUrl;
    }

    public String getAttachmentNombre() {
        return attachmentNombre;
    }

    public void setAttachmentNombre(String attachmentNombre) {
        this.attachmentNombre = attachmentNombre;
    }

    public boolean isFijado() {
        return fijado;
    }

    public void setFijado(boolean fijado) {
        this.fijado = fijado;
    }

    public java.util.Map<String, String> getReacciones() {
        return reacciones;
    }

    public void setReacciones(java.util.Map<String, String> reacciones) {
        this.reacciones = reacciones;
    }

    public String getLugarEncuentro() {
        return lugarEncuentro;
    }

    public void setLugarEncuentro(String lugarEncuentro) {
        this.lugarEncuentro = lugarEncuentro;
    }

    public String getFechaHoraEncuentro() {
        return fechaHoraEncuentro;
    }

    public void setFechaHoraEncuentro(String fechaHoraEncuentro) {
        this.fechaHoraEncuentro = fechaHoraEncuentro;
    }

    public String getEstadoEncuentro() {
        return estadoEncuentro;
    }

    public void setEstadoEncuentro(String estadoEncuentro) {
        this.estadoEncuentro = estadoEncuentro;
    }
}
