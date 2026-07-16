package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

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

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getMascotaId() { return mascotaId; }
    public void setMascotaId(String mascotaId) { this.mascotaId = mascotaId; }

    public String getClinicaId() { return clinicaId; }
    public void setClinicaId(String clinicaId) { this.clinicaId = clinicaId; }

    public String getVeterinarioId() { return veterinarioId; }
    public void setVeterinarioId(String veterinarioId) { this.veterinarioId = veterinarioId; }

    public String getTipoExamen() { return tipoExamen; }
    public void setTipoExamen(String tipoExamen) { this.tipoExamen = tipoExamen; }

    public LocalDateTime getFechaExamen() { return fechaExamen; }
    public void setFechaExamen(LocalDateTime fechaExamen) { this.fechaExamen = fechaExamen; }

    public Map<String, String> getResultados() {
        if (resultados == null) {
            resultados = new HashMap<>();
        }
        return resultados;
    }
    public void setResultados(Map<String, String> resultados) { this.resultados = resultados; }

    public Map<String, String> getRangosReferencia() {
        if (rangosReferencia == null) {
            rangosReferencia = new HashMap<>();
        }
        return rangosReferencia;
    }
    public void setRangosReferencia(Map<String, String> rangosReferencia) { this.rangosReferencia = rangosReferencia; }

    public String getConclusiones() { return conclusiones; }
    public void setConclusiones(String conclusiones) { this.conclusiones = conclusiones; }
}
