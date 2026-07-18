package com.clinicaapp.model;

import com.clinicaapp.model.enums.EstadoPublicacion;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Document(collection = "publicaciones_adopcion")
public class PublicacionAdopcion {

    @Id
    private String id;

    private String nombre;
    private String especie;
    private String raza;
    private String edad;
    private String sexo;
    private String fotoPrincipalUrl;
    private List<String> albumFotos = new ArrayList<>();
    
    private String historia;
    private String motivoAdopcion;
    private String requisitosAdopcion;
    
    private boolean vacunada;
    private boolean esterilizada;
    private boolean aceptaNinos;
    private boolean aceptaOtrasMascotas;
    
    private String nivelEnergia;
    private String tamano;
    private String estadoSalud;
    private String ciudad;
    private String barrio;
    private String tipoViviendaRecomendada;
    private String informacionAdicional;
    
    private EstadoPublicacion estado = EstadoPublicacion.PENDIENTE;
    private LocalDateTime fechaCreacion;
    private LocalDateTime ultimaActualizacion;
    
    private String propietarioId;
    private String nombrePublicador;
    private String tipoPublicador; // "USER" o "CLINICA"
    private String mascotaOriginalId; // Si viene de una mascota registrada
    
    // Estadísticas
    private int vistas = 0;
    private int favoritos = 0;
    private int interesados = 0;

    public PublicacionAdopcion() {
        this.fechaCreacion = LocalDateTime.now();
        this.ultimaActualizacion = LocalDateTime.now();
    }

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

    public String getEspecie() {
        return especie;
    }

    public void setEspecie(String especie) {
        this.especie = especie;
    }

    public String getRaza() {
        return raza;
    }

    public void setRaza(String raza) {
        this.raza = raza;
    }

    public String getEdad() {
        return edad;
    }

    public void setEdad(String edad) {
        this.edad = edad;
    }

    public String getSexo() {
        return sexo;
    }

    public void setSexo(String sexo) {
        this.sexo = sexo;
    }

    public String getFotoPrincipalUrl() {
        return fotoPrincipalUrl;
    }

    public void setFotoPrincipalUrl(String fotoPrincipalUrl) {
        this.fotoPrincipalUrl = fotoPrincipalUrl;
    }

    public List<String> getAlbumFotos() {
        return albumFotos;
    }

    public void setAlbumFotos(List<String> albumFotos) {
        this.albumFotos = albumFotos;
    }

    public String getHistoria() {
        return historia;
    }

    public void setHistoria(String historia) {
        this.historia = historia;
    }

    public String getMotivoAdopcion() {
        return motivoAdopcion;
    }

    public void setMotivoAdopcion(String motivoAdopcion) {
        this.motivoAdopcion = motivoAdopcion;
    }

    public String getRequisitosAdopcion() {
        return requisitosAdopcion;
    }

    public void setRequisitosAdopcion(String requisitosAdopcion) {
        this.requisitosAdopcion = requisitosAdopcion;
    }

    public boolean isVacunada() {
        return vacunada;
    }

    public void setVacunada(boolean vacunada) {
        this.vacunada = vacunada;
    }

    public boolean isEsterilizada() {
        return esterilizada;
    }

    public void setEsterilizada(boolean esterilizada) {
        this.esterilizada = esterilizada;
    }

    public boolean isAceptaNinos() {
        return aceptaNinos;
    }

    public void setAceptaNinos(boolean aceptaNinos) {
        this.aceptaNinos = aceptaNinos;
    }

    public boolean isAceptaOtrasMascotas() {
        return aceptaOtrasMascotas;
    }

    public void setAceptaOtrasMascotas(boolean aceptaOtrasMascotas) {
        this.aceptaOtrasMascotas = aceptaOtrasMascotas;
    }

    public String getNivelEnergia() {
        return nivelEnergia;
    }

    public void setNivelEnergia(String nivelEnergia) {
        this.nivelEnergia = nivelEnergia;
    }

    public String getTamano() {
        return tamano;
    }

    public void setTamano(String tamano) {
        this.tamano = tamano;
    }

    public String getEstadoSalud() {
        return estadoSalud;
    }

    public void setEstadoSalud(String estadoSalud) {
        this.estadoSalud = estadoSalud;
    }

    public String getCiudad() {
        return ciudad;
    }

    public void setCiudad(String ciudad) {
        this.ciudad = ciudad;
    }

    public String getBarrio() {
        return barrio;
    }

    public void setBarrio(String barrio) {
        this.barrio = barrio;
    }

    public String getTipoViviendaRecomendada() {
        return tipoViviendaRecomendada;
    }

    public void setTipoViviendaRecomendada(String tipoViviendaRecomendada) {
        this.tipoViviendaRecomendada = tipoViviendaRecomendada;
    }

    public String getInformacionAdicional() {
        return informacionAdicional;
    }

    public void setInformacionAdicional(String informacionAdicional) {
        this.informacionAdicional = informacionAdicional;
    }

    public EstadoPublicacion getEstado() {
        return estado;
    }

    public void setEstado(EstadoPublicacion estado) {
        this.estado = estado;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public LocalDateTime getUltimaActualizacion() {
        return ultimaActualizacion;
    }

    public void setUltimaActualizacion(LocalDateTime ultimaActualizacion) {
        this.ultimaActualizacion = ultimaActualizacion;
    }

    public String getPropietarioId() {
        return propietarioId;
    }

    public void setPropietarioId(String propietarioId) {
        this.propietarioId = propietarioId;
    }

    public String getNombrePublicador() {
        return nombrePublicador;
    }

    public void setNombrePublicador(String nombrePublicador) {
        this.nombrePublicador = nombrePublicador;
    }

    public String getTipoPublicador() {
        return tipoPublicador;
    }

    public void setTipoPublicador(String tipoPublicador) {
        this.tipoPublicador = tipoPublicador;
    }

    public String getMascotaOriginalId() {
        return mascotaOriginalId;
    }

    public void setMascotaOriginalId(String mascotaOriginalId) {
        this.mascotaOriginalId = mascotaOriginalId;
    }

    public int getVistas() {
        return vistas;
    }

    public void setVistas(int vistas) {
        this.vistas = vistas;
    }

    public int getFavoritos() {
        return favoritos;
    }

    public void setFavoritos(int favoritos) {
        this.favoritos = favoritos;
    }

    public int getInteresados() {
        return interesados;
    }

    public void setInteresados(int interesados) {
        this.interesados = interesados;
    }
}
