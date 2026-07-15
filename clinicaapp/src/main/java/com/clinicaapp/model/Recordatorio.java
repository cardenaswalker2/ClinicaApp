package com.clinicaapp.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "recordatorios")
public class Recordatorio {
    @Id
    private String id;
    private String usuarioId;
    private String titulo;
    private String descripcion;
    private LocalDateTime fechaHora;
    private TipoRecordatorio tipo; // GMAIL, WHATSAPP, AMBOS
    private EstadoRecordatorio estado; // PENDIENTE, ENVIADO, CANCELADO

    public enum TipoRecordatorio {
        GMAIL, SMS, AMBOS
    }

    public enum EstadoRecordatorio {
        PENDIENTE, ENVIADO, CANCELADO
    }
}