package com.clinicaapp.dto;

// import lombok.Data;
// import lombok.NoArgsConstructor;
// import lombok.AllArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

// @Data
// @NoArgsConstructor
// @AllArgsConstructor
public class VisitaDTO {
    private String id;
    private LocalDateTime fechaVisita;
    private String diagnostico;
    private String tratamiento;
    private List<String> medicamentosRecetados;
    private double costoTotal;
    private String notasAdicionales;
    private String citaId;
    private String mascotaId;
    private String clinicaId;
    private String veterinarioId;

    // --- NUEVOS CAMPOS CLÍNICOS ---
    private Double peso;
    private Double temperatura;
    private Integer frecuenciaCardiaca;
    private Integer frecuenciaRespiratoria;
    private String estadoConciencia;
    private String condicionCorporal;
    private LocalDateTime fechaProximaCita;

    public VisitaDTO() {}

    public VisitaDTO(String id, LocalDateTime fechaVisita, String diagnostico, String tratamiento, List<String> medicamentosRecetados, double costoTotal, String notasAdicionales, String citaId, String mascotaId, String clinicaId, String veterinarioId) {
        this.id = id;
        this.fechaVisita = fechaVisita;
        this.diagnostico = diagnostico;
        this.tratamiento = tratamiento;
        this.medicamentosRecetados = medicamentosRecetados;
        this.costoTotal = costoTotal;
        this.notasAdicionales = notasAdicionales;
        this.citaId = citaId;
        this.mascotaId = mascotaId;
        this.clinicaId = clinicaId;
        this.veterinarioId = veterinarioId;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public LocalDateTime getFechaVisita() { return fechaVisita; }
    public void setFechaVisita(LocalDateTime fechaVisita) { this.fechaVisita = fechaVisita; }

    public String getDiagnostico() { return diagnostico; }
    public void setDiagnostico(String diagnostico) { this.diagnostico = diagnostico; }

    public String getTratamiento() { return tratamiento; }
    public void setTratamiento(String tratamiento) { this.tratamiento = tratamiento; }

    public List<String> getMedicamentosRecetados() { return medicamentosRecetados; }
    public void setMedicamentosRecetados(List<String> medicamentosRecetados) { this.medicamentosRecetados = medicamentosRecetados; }

    public double getCostoTotal() { return costoTotal; }
    public void setCostoTotal(double costoTotal) { this.costoTotal = costoTotal; }

    public String getNotasAdicionales() { return notasAdicionales; }
    public void setNotasAdicionales(String notasAdicionales) { this.notasAdicionales = notasAdicionales; }

    public String getCitaId() { return citaId; }
    public void setCitaId(String citaId) { this.citaId = citaId; }

    public String getMascotaId() { return mascotaId; }
    public void setMascotaId(String mascotaId) { this.mascotaId = mascotaId; }

    public String getClinicaId() { return clinicaId; }
    public void setClinicaId(String clinicaId) { this.clinicaId = clinicaId; }

    public String getVeterinarioId() { return veterinarioId; }
    public void setVeterinarioId(String veterinarioId) { this.veterinarioId = veterinarioId; }

    public Double getPeso() { return peso; }
    public void setPeso(Double peso) { this.peso = peso; }

    public Double getTemperatura() { return temperatura; }
    public void setTemperatura(Double temperatura) { this.temperatura = temperatura; }

    public Integer getFrecuenciaCardiaca() { return frecuenciaCardiaca; }
    public void setFrecuenciaCardiaca(Integer frecuenciaCardiaca) { this.frecuenciaCardiaca = frecuenciaCardiaca; }

    public Integer getFrecuenciaRespiratoria() { return frecuenciaRespiratoria; }
    public void setFrecuenciaRespiratoria(Integer frecuenciaRespiratoria) { this.frecuenciaRespiratoria = frecuenciaRespiratoria; }

    public String getEstadoConciencia() { return estadoConciencia; }
    public void setEstadoConciencia(String estadoConciencia) { this.estadoConciencia = estadoConciencia; }

    public String getCondicionCorporal() { return condicionCorporal; }
    public void setCondicionCorporal(String condicionCorporal) { this.condicionCorporal = condicionCorporal; }

    public LocalDateTime getFechaProximaCita() { return fechaProximaCita; }
    public void setFechaProximaCita(LocalDateTime fechaProximaCita) { this.fechaProximaCita = fechaProximaCita; }

    // --- NUEVOS CAMPOS CLÍNICOS AVANZADOS ---
    private String anamnesis;
    private String sintomas;
    private String tiempoEvolucion;
    private String diagnosticoPrincipal;
    private String diagnosticosSecundarios;
    private String gravedad;
    private String procedimientosRealizados;
    private String recomendacionesPropietario;
    private String vacunasAplicadas;
    private String proximaVacunacion;
    private List<String> adjuntosUrls;
    private boolean bloqueada;

    public String getAnamnesis() { return anamnesis; }
    public void setAnamnesis(String anamnesis) { this.anamnesis = anamnesis; }

    public String getSintomas() { return sintomas; }
    public void setSintomas(String sintomas) { this.sintomas = sintomas; }

    public String getTiempoEvolucion() { return tiempoEvolucion; }
    public void setTiempoEvolucion(String tiempoEvolucion) { this.tiempoEvolucion = tiempoEvolucion; }

    public String getDiagnosticoPrincipal() { return diagnosticoPrincipal; }
    public void setDiagnosticoPrincipal(String diagnosticoPrincipal) { this.diagnosticoPrincipal = diagnosticoPrincipal; }

    public String getDiagnosticosSecundarios() { return diagnosticosSecundarios; }
    public void setDiagnosticosSecundarios(String diagnosticosSecundarios) { this.diagnosticosSecundarios = diagnosticosSecundarios; }

    public String getGravedad() { return gravedad; }
    public void setGravedad(String gravedad) { this.gravedad = gravedad; }

    public String getProcedimientosRealizados() { return procedimientosRealizados; }
    public void setProcedimientosRealizados(String procedimientosRealizados) { this.procedimientosRealizados = procedimientosRealizados; }

    public String getRecomendacionesPropietario() { return recomendacionesPropietario; }
    public void setRecomendacionesPropietario(String recomendacionesPropietario) { this.recomendacionesPropietario = recomendacionesPropietario; }

    public String getVacunasAplicadas() { return vacunasAplicadas; }
    public void setVacunasAplicadas(String vacunasAplicadas) { this.vacunasAplicadas = vacunasAplicadas; }

    public String getProximaVacunacion() { return proximaVacunacion; }
    public void setProximaVacunacion(String proximaVacunacion) { this.proximaVacunacion = proximaVacunacion; }

    public List<String> getAdjuntosUrls() { return adjuntosUrls; }
    public void setAdjuntosUrls(List<String> adjuntosUrls) { this.adjuntosUrls = adjuntosUrls; }

    public boolean isBloqueada() { return bloqueada; }
    public void setBloqueada(boolean bloqueada) { this.bloqueada = bloqueada; }
}