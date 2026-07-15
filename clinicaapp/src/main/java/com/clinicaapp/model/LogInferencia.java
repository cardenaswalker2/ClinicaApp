package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "logs_inferencia")
public class LogInferencia {

    @Id
    private String id;
    
    private String usuarioId;
    private String nombreUsuario; // Denormalized para lecturas rápidas sin JOINs
    
    private String promptUsuario;
    private String respuestaIA;
    
    private String motorUtilizado; // e.g. "Groq Llama 3", "Regex Heuristics", "Weka Engine"
    private String intentDetectado; // e.g. "SALUD_CONSEJO", "GOTO_SOLICITAR_CITA"
    
    private LocalDateTime fecha;

    public LogInferencia() {
        this.fecha = LocalDateTime.now();
    }

    public LogInferencia(String usuarioId, String nombreUsuario, String promptUsuario, String respuestaIA, String motorUtilizado, String intentDetectado) {
        this.usuarioId = usuarioId;
        this.nombreUsuario = nombreUsuario;
        this.promptUsuario = promptUsuario;
        this.respuestaIA = respuestaIA;
        this.motorUtilizado = motorUtilizado;
        this.intentDetectado = intentDetectado;
        this.fecha = LocalDateTime.now();
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

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }

    public String getPromptUsuario() {
        return promptUsuario;
    }

    public void setPromptUsuario(String promptUsuario) {
        this.promptUsuario = promptUsuario;
    }

    public String getRespuestaIA() {
        return respuestaIA;
    }

    public void setRespuestaIA(String respuestaIA) {
        this.respuestaIA = respuestaIA;
    }

    public String getMotorUtilizado() {
        return motorUtilizado;
    }

    public void setMotorUtilizado(String motorUtilizado) {
        this.motorUtilizado = motorUtilizado;
    }

    public String getIntentDetectado() {
        return intentDetectado;
    }

    public void setIntentDetectado(String intentDetectado) {
        this.intentDetectado = intentDetectado;
    }

    public LocalDateTime getFecha() {
        return fecha;
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }
}
