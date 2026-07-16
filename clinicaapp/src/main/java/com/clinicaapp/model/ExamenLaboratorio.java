package com.clinicaapp.model;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Data
@Document(collection = "examenes_laboratorio")
public class ExamenLaboratorio {
    @Id
    private String id;
    private String mascotaId;
    private String clinicaId;
    private String veterinarioId;
    private String tipoExamen; // Ej: "Hemograma", "Bioquímica", "Uroanálisis"
    private LocalDateTime fechaExamen;
    private Map<String, String> resultados = new HashMap<>();
    private Map<String, String> rangosReferencia = new HashMap<>();
    private String conclusiones;

    public ExamenLaboratorio() {}

    public ExamenLaboratorio(String mascotaId, String clinicaId, String veterinarioId, String tipoExamen, LocalDateTime fechaExamen, String conclusiones) {
        this.mascotaId = mascotaId;
        this.clinicaId = clinicaId;
        this.veterinarioId = veterinarioId;
        this.tipoExamen = tipoExamen;
        this.fechaExamen = fechaExamen;
        this.conclusiones = conclusiones;
    }
}
