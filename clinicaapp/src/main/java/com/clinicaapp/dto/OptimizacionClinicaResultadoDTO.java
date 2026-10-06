package com.clinicaapp.dto;

import java.util.List;
import java.util.Map;

/**
 * DTO que encapsula los resultados y la formulación matemática
 * del modelo de Investigación de Operaciones (Programación Lineal Entera Binaria)
 * para la selección óptima de clínicas según la ubicación del usuario.
 */
public class OptimizacionClinicaResultadoDTO {

    // Ubicación del usuario evaluada
    private double userLat;
    private double userLng;
    private String userAddress;
    private double radioMaxKm;

    // Clínica Óptima (Solución: X_i = 1)
    private ClinicaOptimaDTO clinicaSeleccionada;
    private double distanciaMinimaKm; // Valor de la Función Objetivo Z*

    // Datos del Modelo Matemático
    private String funcionObjetivoFormula; // Min Z = d1*X1 + d2*X2 + ...
    private List<String> restricciones;    // X1 + X2 + ... = 1, di*Xi <= Dmax, etc.
    private List<VariableClinicaDTO> variablesDecision; // X1, X2, ... con sus distancias di, Ai, y valor asignado (0 o 1)

    // Resumen estadístico
    private int totalClinicasEvaluadas;
    private int clinicasFactibles;
    private int clinicasDescartadasPorRadio;
    private int clinicasDescartadasPorDisponibilidad;
    private boolean solucionEncontrada;
    private String mensaje;

    public OptimizacionClinicaResultadoDTO() {}

    // --- Sub-clases DTO para variables y clínica seleccionada ---

    public static class VariableClinicaDTO {
        private String variableNombre; // Ej: "X1", "X2"
        private String clinicaId;
        private String clinicaNombre;
        private String direccion;
        private double latitud;
        private double longitud;
        private double distanciaKm; // d_i (coeficiente en la función objetivo, >= 0)
        private boolean disponible; // A_i (1 o 0)
        private boolean cumpleRadio; // d_i <= D_max
        private boolean esFactible;  // Cumple todas las restricciones
        private int valorOptimo;     // 1 si fue seleccionada por el modelo, 0 si no
        private String motivoDescarte;

        public VariableClinicaDTO() {}

        public VariableClinicaDTO(String variableNombre, String clinicaId, String clinicaNombre, 
                                  String direccion, double latitud, double longitud, 
                                  double distanciaKm, boolean disponible, boolean cumpleRadio, 
                                  boolean esFactible, int valorOptimo, String motivoDescarte) {
            this.variableNombre = variableNombre;
            this.clinicaId = clinicaId;
            this.clinicaNombre = clinicaNombre;
            this.direccion = direccion;
            this.latitud = latitud;
            this.longitud = longitud;
            this.distanciaKm = distanciaKm;
            this.disponible = disponible;
            this.cumpleRadio = cumpleRadio;
            this.esFactible = esFactible;
            this.valorOptimo = valorOptimo;
            this.motivoDescarte = motivoDescarte;
        }

        // Getters y Setters
        public String getVariableNombre() { return variableNombre; }
        public void setVariableNombre(String variableNombre) { this.variableNombre = variableNombre; }
        public String getClinicaId() { return clinicaId; }
        public void setClinicaId(String clinicaId) { this.clinicaId = clinicaId; }
        public String getClinicaNombre() { return clinicaNombre; }
        public void setClinicaNombre(String clinicaNombre) { this.clinicaNombre = clinicaNombre; }
        public String getDireccion() { return direccion; }
        public void setDireccion(String direccion) { this.direccion = direccion; }
        public double getLatitud() { return latitud; }
        public void setLatitud(double latitud) { this.latitud = latitud; }
        public double getLongitud() { return longitud; }
        public void setLongitud(double longitud) { this.longitud = longitud; }
        public double getDistanciaKm() { return distanciaKm; }
        public void setDistanciaKm(double distanciaKm) { this.distanciaKm = distanciaKm; }
        public boolean isDisponible() { return disponible; }
        public void setDisponible(boolean disponible) { this.disponible = disponible; }
        public boolean isCumpleRadio() { return cumpleRadio; }
        public void setCumpleRadio(boolean cumpleRadio) { this.cumpleRadio = cumpleRadio; }
        public boolean isEsFactible() { return esFactible; }
        public void setEsFactible(boolean esFactible) { this.esFactible = esFactible; }
        public int getValorOptimo() { return valorOptimo; }
        public void setValorOptimo(int valorOptimo) { this.valorOptimo = valorOptimo; }
        public String getMotivoDescarte() { return motivoDescarte; }
        public void setMotivoDescarte(String motivoDescarte) { this.motivoDescarte = motivoDescarte; }
    }

    public static class ClinicaOptimaDTO {
        private String id;
        private String nombre;
        private String direccion;
        private String telefono;
        private String email;
        private String descripcion;
        private String imagenUrl;
        private double latitud;
        private double longitud;
        private double distanciaKm;
        private String horarioAtencion;

        public ClinicaOptimaDTO() {}

        // Getters y Setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getNombre() { return nombre; }
        public void setNombre(String nombre) { this.nombre = nombre; }
        public String getDireccion() { return direccion; }
        public void setDireccion(String direccion) { this.direccion = direccion; }
        public String getTelefono() { return telefono; }
        public void setTelefono(String telefono) { this.telefono = telefono; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getDescripcion() { return descripcion; }
        public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
        public String getImagenUrl() { return imagenUrl; }
        public void setImagenUrl(String imagenUrl) { this.imagenUrl = imagenUrl; }
        public double getLatitud() { return latitud; }
        public void setLatitud(double latitud) { this.latitud = latitud; }
        public double getLongitud() { return longitud; }
        public void setLongitud(double longitud) { this.longitud = longitud; }
        public double getDistanciaKm() { return distanciaKm; }
        public void setDistanciaKm(double distanciaKm) { this.distanciaKm = distanciaKm; }
        public String getHorarioAtencion() { return horarioAtencion; }
        public void setHorarioAtencion(String horarioAtencion) { this.horarioAtencion = horarioAtencion; }
    }

    // --- Getters y Setters de la clase principal ---
    public double getUserLat() { return userLat; }
    public void setUserLat(double userLat) { this.userLat = userLat; }
    public double getUserLng() { return userLng; }
    public void setUserLng(double userLng) { this.userLng = userLng; }
    public String getUserAddress() { return userAddress; }
    public void setUserAddress(String userAddress) { this.userAddress = userAddress; }
    public double getRadioMaxKm() { return radioMaxKm; }
    public void setRadioMaxKm(double radioMaxKm) { this.radioMaxKm = radioMaxKm; }
    public ClinicaOptimaDTO getClinicaSeleccionada() { return clinicaSeleccionada; }
    public void setClinicaSeleccionada(ClinicaOptimaDTO clinicaSeleccionada) { this.clinicaSeleccionada = clinicaSeleccionada; }
    public double getDistanciaMinimaKm() { return distanciaMinimaKm; }
    public void setDistanciaMinimaKm(double distanciaMinimaKm) { this.distanciaMinimaKm = distanciaMinimaKm; }
    public String getFuncionObjetivoFormula() { return funcionObjetivoFormula; }
    public void setFuncionObjetivoFormula(String funcionObjetivoFormula) { this.funcionObjetivoFormula = funcionObjetivoFormula; }
    public List<String> getRestricciones() { return restricciones; }
    public void setRestricciones(List<String> restricciones) { this.restricciones = restricciones; }
    public List<VariableClinicaDTO> getVariablesDecision() { return variablesDecision; }
    public void setVariablesDecision(List<VariableClinicaDTO> variablesDecision) { this.variablesDecision = variablesDecision; }
    public int getTotalClinicasEvaluadas() { return totalClinicasEvaluadas; }
    public void setTotalClinicasEvaluadas(int totalClinicasEvaluadas) { this.totalClinicasEvaluadas = totalClinicasEvaluadas; }
    public int getClinicasFactibles() { return clinicasFactibles; }
    public void setClinicasFactibles(int clinicasFactibles) { this.clinicasFactibles = clinicasFactibles; }
    public int getClinicasDescartadasPorRadio() { return clinicasDescartadasPorRadio; }
    public void setClinicasDescartadasPorRadio(int clinicasDescartadasPorRadio) { this.clinicasDescartadasPorRadio = clinicasDescartadasPorRadio; }
    public int getClinicasDescartadasPorDisponibilidad() { return clinicasDescartadasPorDisponibilidad; }
    public void setClinicasDescartadasPorDisponibilidad(int clinicasDescartadasPorDisponibilidad) { this.clinicasDescartadasPorDisponibilidad = clinicasDescartadasPorDisponibilidad; }
    public boolean isSolucionEncontrada() { return solucionEncontrada; }
    public void setSolucionEncontrada(boolean solucionEncontrada) { this.solucionEncontrada = solucionEncontrada; }
    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }
}
