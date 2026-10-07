package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Document(collection = "usuarios_actividad")
public class UsuarioActividad {

    @Id
    private String id;
    private String usuarioId;
    private String email;
    private String nombre;
    private String tipoEvento; // LOGIN, LOGOUT, NAVEGACION, ACCION, DETALLE, CAMBIO_SECCION
    private String seccion;     // Dashboard, Citas, Historial, Perfil, Mascotas, etc.
    private String accion;      // Descripción detallada del evento
    private String url;         // Ruta o URL interna visitada
    private String ip;
    private String dispositivo; // Desktop, Mobile, etc.
    private String navegador;
    private LocalDateTime fechaHora;
    private String metadata;    // Información adicional no sensible

    public UsuarioActividad() {
        this.fechaHora = LocalDateTime.now();
    }

    public UsuarioActividad(String usuarioId, String email, String nombre, String tipoEvento, 
                            String seccion, String accion, String url, String ip, 
                            String dispositivo, String navegador, String metadata) {
        this.usuarioId = usuarioId;
        this.email = email;
        this.nombre = nombre;
        this.tipoEvento = tipoEvento;
        this.seccion = seccion;
        this.accion = accion;
        this.url = url;
        this.ip = ip;
        this.dispositivo = dispositivo;
        this.navegador = navegador;
        this.metadata = metadata;
        this.fechaHora = LocalDateTime.now();
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(String usuarioId) {
        this.usuarioId = usuarioId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTipoEvento() {
        return tipoEvento;
    }

    public void setTipoEvento(String tipoEvento) {
        this.tipoEvento = tipoEvento;
    }

    public String getSeccion() {
        return seccion;
    }

    public void setSeccion(String seccion) {
        this.seccion = seccion;
    }

    public String getAccion() {
        return accion;
    }

    public void setAccion(String accion) {
        this.accion = accion;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public String getDispositivo() {
        return dispositivo;
    }

    public void setDispositivo(String dispositivo) {
        this.dispositivo = dispositivo;
    }

    public String getNavegador() {
        return navegador;
    }

    public void setNavegador(String navegador) {
        this.navegador = navegador;
    }

    public LocalDateTime getFechaHora() {
        return fechaHora;
    }

    public void setFechaHora(LocalDateTime fechaHora) {
        this.fechaHora = fechaHora;
    }

    public String getMetadata() {
        return metadata;
    }

    public void setMetadata(String metadata) {
        this.metadata = metadata;
    }
}
