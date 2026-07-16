package com.clinicaapp.model;

import com.clinicaapp.model.enums.Especie;
import com.clinicaapp.model.enums.RazaGato;
import com.clinicaapp.model.enums.RazaPerro;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDate;

// Hemos quitado @Data, @NoArgsConstructor y @AllArgsConstructor temporalmente para poner todo explícito
@Document(collection = "mascotas")
public class Mascota {

    @Id
    private String id;

    private String nombre;
    private Especie especie;
    private RazaPerro razaPerro;
    private RazaGato razaGato;
    private LocalDate fechaNacimiento;
    private String propietarioId;
    private String sexo;
    private String fotoUrl;
    private String razaPersonalizada;
    private java.util.List<String> albumFotos = new java.util.ArrayList<>();

    // --- NUEVOS CAMPOS CLÍNICOS ---
    private java.util.List<String> alergias = new java.util.ArrayList<>();
    private java.util.Map<String, Double> pesoHistorico = new java.util.LinkedHashMap<>();
    private java.util.List<String> vacunas = new java.util.ArrayList<>();
    private java.util.List<String> desparasitaciones = new java.util.ArrayList<>();
    private java.util.List<String> historialCirugias = new java.util.ArrayList<>();
    private java.util.List<String> adjuntosClinicos = new java.util.ArrayList<>();
    private String alertasMedicas;


    // --- Constructor Vacío (Obligatorio para Spring Data) ---
    public Mascota() {
    }

    // --- Constructor con todos los campos (útil para pruebas) ---
    public Mascota(String id, String nombre, Especie especie, RazaPerro razaPerro, RazaGato razaGato,
            LocalDate fechaNacimiento, String propietarioId) {
        this.id = id;
        this.nombre = nombre;
        this.especie = especie;
        this.razaPerro = razaPerro;
        this.razaGato = razaGato;
        this.fechaNacimiento = fechaNacimiento;
        this.propietarioId = propietarioId;
        this.sexo = "No especificado";
    }

    // --- Getters y Setters explícitos ---
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Especie getEspecie() {
        return especie;
    }

    public void setEspecie(Especie especie) {
        this.especie = especie;
    }

    public RazaPerro getRazaPerro() {
        return razaPerro;
    }

    public void setRazaPerro(RazaPerro razaPerro) {
        this.razaPerro = razaPerro;
    }

    public RazaGato getRazaGato() {
        return razaGato;
    }

    public void setRazaGato(RazaGato razaGato) {
        this.razaGato = razaGato;
    }

    public LocalDate getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(LocalDate fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public String getPropietarioId() {
        return propietarioId;
    }

    public void setPropietarioId(String propietarioId) {
        this.propietarioId = propietarioId;
    }

    public String getSexo() {
        return sexo;
    }

    public void setSexo(String sexo) {
        this.sexo = sexo;
    }

    public String getFotoUrl() {
        return fotoUrl;
    }

    public void setFotoUrl(String fotoUrl) {
        this.fotoUrl = fotoUrl;
    }

    public String getRazaPersonalizada() {
        return razaPersonalizada;
    }

    public void setRazaPersonalizada(String razaPersonalizada) {
        this.razaPersonalizada = razaPersonalizada;
    }

    public java.util.List<String> getAlbumFotos() {
        return albumFotos;
    }

    public void setAlbumFotos(java.util.List<String> albumFotos) {
        this.albumFotos = albumFotos;
    }

    // --- toString() para depuración ---
    @Override
    public String toString() {
        return "Mascota{" +
                "id='" + id + '\'' +
                ", nombre='" + nombre + '\'' +
                ", especie=" + especie +
                ", razaPerro=" + razaPerro +
                ", razaGato=" + razaGato +
                ", fechaNacimiento=" + fechaNacimiento +
                ", propietarioId='" + propietarioId + '\'' +
                ", sexo='" + sexo + '\'' + // <-- Añadido a toString
                '}';
    }

    public String getRaza() {
        if (this.razaPersonalizada != null && !this.razaPersonalizada.trim().isEmpty()) {
            return this.razaPersonalizada;
        }
        if (this.especie == null) return "Especie no especificada";
        
        if (this.especie == Especie.PERRO) {
            return (this.razaPerro != null) ? this.razaPerro.name() : "Raza de perro no especificada";
        } else if (this.especie == Especie.GATO) {
            return (this.razaGato != null) ? this.razaGato.name() : "Raza de gato no especificada";
        } else if (this.especie == Especie.OTRO) {
            return "Otra especie";
        }
        return "Raza no especificada";
    }
    public int getEdad() {
        if (this.fechaNacimiento != null) {
            // Calcula los años entre la fecha de nacimiento y hoy
            return java.time.Period.between(this.fechaNacimiento, java.time.LocalDate.now()).getYears();
        }
        return 0; // Si no hay fecha, devuelve 0
    }

    public java.util.List<String> getAlergias() {
        if (alergias == null) alergias = new java.util.ArrayList<>();
        return alergias;
    }

    public void setAlergias(java.util.List<String> alergias) {
        this.alergias = alergias;
    }

    public java.util.Map<String, Double> getPesoHistorico() {
        if (pesoHistorico == null) pesoHistorico = new java.util.LinkedHashMap<>();
        return pesoHistorico;
    }

    public void setPesoHistorico(java.util.Map<String, Double> pesoHistorico) {
        this.pesoHistorico = pesoHistorico;
    }

    public java.util.List<String> getVacunas() {
        if (vacunas == null) vacunas = new java.util.ArrayList<>();
        return vacunas;
    }

    public void setVacunas(java.util.List<String> vacunas) {
        this.vacunas = vacunas;
    }

    public java.util.List<String> getDesparasitaciones() {
        if (desparasitaciones == null) desparasitaciones = new java.util.ArrayList<>();
        return desparasitaciones;
    }

    public void setDesparasitaciones(java.util.List<String> desparasitaciones) {
        this.desparasitaciones = desparasitaciones;
    }

    public java.util.List<String> getHistorialCirugias() {
        if (historialCirugias == null) historialCirugias = new java.util.ArrayList<>();
        return historialCirugias;
    }

    public void setHistorialCirugias(java.util.List<String> historialCirugias) {
        this.historialCirugias = historialCirugias;
    }

    public java.util.List<String> getAdjuntosClinicos() {
        if (adjuntosClinicos == null) adjuntosClinicos = new java.util.ArrayList<>();
        return adjuntosClinicos;
    }

    public void setAdjuntosClinicos(java.util.List<String> adjuntosClinicos) {
        this.adjuntosClinicos = adjuntosClinicos;
    }

    public String getAlertasMedicas() {
        return alertasMedicas;
    }

    public void setAlertasMedicas(String alertasMedicas) {
        this.alertasMedicas = alertasMedicas;
    }
}