package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Document(collection = "recordatorios")
public class Recordatorio {
    @Id
    private String id;
    private String usuarioId;
    private String titulo;
    private String descripcion;
    private LocalDateTime fechaHora;
    private TipoRecordatorio tipo; // GMAIL, SMS, AMBOS
    private EstadoRecordatorio estado; // PENDIENTE, ENVIADO, CANCELADO

    public enum TipoRecordatorio {
        GMAIL, SMS, AMBOS
    }

    public enum EstadoRecordatorio {
        PENDIENTE, ENVIADO, CANCELADO
    }

    public Recordatorio() {}

    public Recordatorio(String id, String usuarioId, String titulo, String descripcion, LocalDateTime fechaHora, TipoRecordatorio tipo, EstadoRecordatorio estado) {
        this.id = id;
        this.usuarioId = usuarioId;
        this.titulo = titulo;
        this.descripcion = descripcion;
        this.fechaHora = fechaHora;
        this.tipo = tipo;
        this.estado = estado;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUsuarioId() { return usuarioId; }
    public void setUsuarioId(String usuarioId) { this.usuarioId = usuarioId; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public LocalDateTime getFechaHora() { return fechaHora; }
    public void setFechaHora(LocalDateTime fechaHora) { this.fechaHora = fechaHora; }

    public TipoRecordatorio getTipo() { return tipo; }
    public void setTipo(TipoRecordatorio tipo) { this.tipo = tipo; }

    public EstadoRecordatorio getEstado() { return estado; }
    public void setEstado(EstadoRecordatorio estado) { this.estado = estado; }
}