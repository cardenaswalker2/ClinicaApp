package com.clinicaapp.model;

import com.clinicaapp.model.enums.Role;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Document(collection = "usuarios")
public class Usuario {

    @Id
    private String id;
    private String nombre;
    private String apellido;
    private String email;
    private String password;
    private String telefono;
    private Role role;
    private String resetPasswordToken;
    private LocalDateTime resetPasswordTokenExpiry;
    private LocalDateTime fechaCreacion;

    // --- NUEVO CAMPO PARA CONTROL DE SEGURIDAD ---
    private boolean activo = true;

    // --- NUEVO CAMPO PARA FOTO DE PERFIL ---
    private String fotoUrl;

    private java.util.List<Double> descriptorFacial;

    // Indica si el usuario ya registró su rostro exitosamente
    private boolean facialLoginHabilitado = false;

    // --- NUEVOS CAMPOS SAAS ENTERPRISE ---
    private String clinicaId; // ID de la clínica a la que pertenece el empleado
    private java.util.List<String> diasLaborales = java.util.Arrays.asList("LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES");
    private String horaInicioTrabajo = "08:00";
    private String horaFinTrabajo = "17:00";
    private java.util.List<String> diasLibresVacaciones = new java.util.ArrayList<>();

    // --- MÁS CAMPOS SAAS DE PERSONAL ---
    private String fotoPerfilUrl;
    private String documento;
    private String direccion;
    private String cargo;
    private String especialidad;
    private String nLicencia;
    private String fechaIngreso;
    private String estadoEmpleado = "Activo";
    private String biografia;
    private String observacionesInternas;
    private String horaInicioDescanso = "13:00";
    private String horaFinDescanso = "14:00";
    private java.util.List<String> consultoriosDisponibles = new java.util.ArrayList<>();
    private Double calificacion = 5.0;
    private Integer experiencia = 0;



    // Constructor vacío
    public Usuario() {
    }

    // Constructor con todos los campos (Actualizado con 'activo')
    public Usuario(String id, String nombre, String apellido, String email, String password,
            String telefono, Role role, String resetPasswordToken,
            LocalDateTime resetPasswordTokenExpiry, LocalDateTime fechaCreacion,
            boolean activo, java.util.List<Double> descriptorFacial, boolean facialLoginHabilitado) {
        this.id = id;
        this.nombre = nombre;
        this.apellido = apellido;
        this.email = email;
        this.password = password;
        this.telefono = telefono;
        this.role = role;
        this.resetPasswordToken = resetPasswordToken;
        this.resetPasswordTokenExpiry = resetPasswordTokenExpiry;
        this.fechaCreacion = fechaCreacion;
        this.activo = activo;
        this.descriptorFacial = descriptorFacial;
        this.facialLoginHabilitado = facialLoginHabilitado;
    }

    // Constructor sin ID (Actualizado)
    public Usuario(String nombre, String apellido, String email, String password,
            String telefono, Role role) {
        this.nombre = nombre;
        this.apellido = apellido;
        this.email = email;
        this.password = password;
        this.telefono = telefono;
        this.role = role;
        this.fechaCreacion = LocalDateTime.now();
        this.activo = true; // Por defecto activo al crearse
    }

    // --- GETTERS Y SETTERS EXISTENTES ---
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

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getResetPasswordToken() {
        return resetPasswordToken;
    }

    public void setResetPasswordToken(String resetPasswordToken) {
        this.resetPasswordToken = resetPasswordToken;
    }

    public LocalDateTime getResetPasswordTokenExpiry() {
        return resetPasswordTokenExpiry;
    }

    public void setResetPasswordTokenExpiry(LocalDateTime resetPasswordTokenExpiry) {
        this.resetPasswordTokenExpiry = resetPasswordTokenExpiry;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    // --- NUEVO GETTER Y SETTER PARA 'ACTIVO' ---
    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    // Helper methods para Thymeleaf
    public String getNombreCompleto() {
        String nom = nombre != null ? nombre : "";
        String ape = apellido != null ? apellido : "";
        return (nom + " " + ape).trim();
    }

    public String getIniciales() {
        String iniNom = (nombre != null && !nombre.isEmpty()) ? nombre.substring(0, 1) : "N";
        String iniApe = (apellido != null && !apellido.isEmpty()) ? apellido.substring(0, 1) : "N";
        return (iniNom + iniApe).toUpperCase();
    }

    public java.util.List<Double> getDescriptorFacial() {
        return descriptorFacial;
    }

    public void setDescriptorFacial(java.util.List<Double> descriptorFacial) {
        this.descriptorFacial = descriptorFacial;
    }

    public boolean isFacialLoginHabilitado() {
        return facialLoginHabilitado;
    }

    public void setFacialLoginHabilitado(boolean facialLoginHabilitado) {
        this.facialLoginHabilitado = facialLoginHabilitado;
    }

    public String getFotoUrl() {
        return fotoUrl;
    }

    public void setFotoUrl(String fotoUrl) {
        this.fotoUrl = fotoUrl;
    }

    // --- GETTERS Y SETTERS PARA SAAS ENTERPRISE ---
    public String getClinicaId() {
        return clinicaId;
    }

    public void setClinicaId(String clinicaId) {
        this.clinicaId = clinicaId;
    }

    public java.util.List<String> getDiasLaborales() {
        if (diasLaborales == null) {
            diasLaborales = java.util.Arrays.asList("LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES");
        }
        return diasLaborales;
    }

    public void setDiasLaborales(java.util.List<String> diasLaborales) {
        this.diasLaborales = diasLaborales;
    }

    public String getHoraInicioTrabajo() {
        return horaInicioTrabajo != null ? horaInicioTrabajo : "08:00";
    }

    public void setHoraInicioTrabajo(String horaInicioTrabajo) {
        this.horaInicioTrabajo = horaInicioTrabajo;
    }

    public String getHoraFinTrabajo() {
        return horaFinTrabajo != null ? horaFinTrabajo : "17:00";
    }

    public void setHoraFinTrabajo(String horaFinTrabajo) {
        this.horaFinTrabajo = horaFinTrabajo;
    }

    public java.util.List<String> getDiasLibresVacaciones() {
        if (diasLibresVacaciones == null) {
            diasLibresVacaciones = new java.util.ArrayList<>();
        }
        return diasLibresVacaciones;
    }

    public void setDiasLibresVacaciones(java.util.List<String> diasLibresVacaciones) {
        this.diasLibresVacaciones = diasLibresVacaciones;
    }

    public String getFotoPerfilUrl() { return fotoPerfilUrl; }
    public void setFotoPerfilUrl(String fotoPerfilUrl) { this.fotoPerfilUrl = fotoPerfilUrl; }
    public String getDocumento() { return documento; }
    public void setDocumento(String documento) { this.documento = documento; }
    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }
    public String getCargo() { return cargo; }
    public void setCargo(String cargo) { this.cargo = cargo; }
    public String getEspecialidad() { return especialidad; }
    public void setEspecialidad(String especialidad) { this.especialidad = especialidad; }
    public String getnLicencia() { return nLicencia; }
    public void setnLicencia(String nLicencia) { this.nLicencia = nLicencia; }
    public String getFechaIngreso() { return fechaIngreso; }
    public void setFechaIngreso(String fechaIngreso) { this.fechaIngreso = fechaIngreso; }
    public String getEstadoEmpleado() { return estadoEmpleado != null ? estadoEmpleado : "Activo"; }
    public void setEstadoEmpleado(String estadoEmpleado) { this.estadoEmpleado = estadoEmpleado; }
    public String getBiografia() { return biografia; }
    public void setBiografia(String biografia) { this.biografia = biografia; }
    public String getObservacionesInternas() { return observacionesInternas; }
    public void setObservacionesInternas(String observacionesInternas) { this.observacionesInternas = observacionesInternas; }
    public String getHoraInicioDescanso() { return horaInicioDescanso != null ? horaInicioDescanso : "13:00"; }
    public void setHoraInicioDescanso(String horaInicioDescanso) { this.horaInicioDescanso = horaInicioDescanso; }
    public String getHoraFinDescanso() { return horaFinDescanso != null ? horaFinDescanso : "14:00"; }
    public void setHoraFinDescanso(String horaFinDescanso) { this.horaFinDescanso = horaFinDescanso; }
    public java.util.List<String> getConsultoriosDisponibles() {
        if (consultoriosDisponibles == null) {
            consultoriosDisponibles = new java.util.ArrayList<>();
        }
        return consultoriosDisponibles;
    }
    public void setConsultoriosDisponibles(java.util.List<String> consultoriosDisponibles) { this.consultoriosDisponibles = consultoriosDisponibles; }
    public Double getCalificacion() { return calificacion != null ? calificacion : 5.0; }
    public void setCalificacion(Double calificacion) { this.calificacion = calificacion; }
    public Integer getExperiencia() { return experiencia != null ? experiencia : 0; }
    public void setExperiencia(Integer experiencia) { this.experiencia = experiencia; }
}