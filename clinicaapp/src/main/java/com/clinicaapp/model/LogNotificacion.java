package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "logs_notificacion")
public class LogNotificacion {

    @Id
    private String id;
    private LocalDateTime fecha;
    private String tipo; // EMAIL, SMS, WHATSAPP
    private String destinatario; // Correo o Teléfono
    private String asunto; // Null para SMS/WhatsApp
    private String mensaje; // Cuerpo de texto o HTML completo
    private String estado; // SUCCESS, FAILED
    private String detalles; // Twilio SID, JavaMail logs de error, etc.

    // Constructor vacío (Requerido por Spring Data MongoDB)
    public LogNotificacion() {}

    // Constructor completo
    public LogNotificacion(LocalDateTime fecha, String tipo, String destinatario, String asunto, String mensaje, String estado, String detalles) {
        this.fecha = fecha;
        this.tipo = tipo;
        this.destinatario = destinatario;
        this.asunto = asunto;
        this.mensaje = mensaje;
        this.estado = estado;
        this.detalles = detalles;
    }

    // Getters y Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public LocalDateTime getFecha() {
        return fecha;
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getDestinatario() {
        return destinatario;
    }

    public void setDestinatario(String destinatario) {
        this.destinatario = destinatario;
    }

    public String getAsunto() {
        return asunto;
    }

    public void setAsunto(String asunto) {
        this.asunto = asunto;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getDetalles() {
        return detalles;
    }

    public void setDetalles(String detalles) {
        this.detalles = detalles;
    }

    // Helpers visuales para Thymeleaf
    public String getIcono() {
        if ("EMAIL".equalsIgnoreCase(tipo)) {
            return "bi-envelope-fill text-info";
        } else if ("WHATSAPP".equalsIgnoreCase(tipo)) {
            return "bi-whatsapp text-success";
        } else {
            return "bi-chat-left-text-fill text-warning";
        }
    }
}
