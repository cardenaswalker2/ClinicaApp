package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "configuracion")
public class ConfiguracionGlobal {

    @Id
    private String id = "GLOBAL_SETTINGS";

    private double comisionStripe = 10.0;
    private String emailContacto = "soporte@clinicaapp.com";
    private String telefonoSoporte = "+57 300 572 2844";
    private String mensajeBienvenida = "¡Bienvenido a ClínicaApp!";
    private boolean sistemaActivo = true; 
    private boolean modoMantenimiento = false;
    private String mensajeGlobal = "";
    private String broadcastColor = "info"; // info, warning, danger
    private boolean broadcastActivo = false;
    private int minutosParaCierre = 1;
    private java.time.LocalDateTime mantenimientoDesde;

    // Constructor vacío
    public ConfiguracionGlobal() {}

    // --- GETTERS Y SETTERS ---

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public double getComisionStripe() { return comisionStripe; }
    public void setComisionStripe(double comisionStripe) { this.comisionStripe = comisionStripe; }

    public String getEmailContacto() { return emailContacto; }
    public void setEmailContacto(String emailContacto) { this.emailContacto = emailContacto; }

    public String getTelefonoSoporte() { return telefonoSoporte; }
    public void setTelefonoSoporte(String telefonoSoporte) { this.telefonoSoporte = telefonoSoporte; }

    public String getMensajeBienvenida() { return mensajeBienvenida; }
    public void setMensajeBienvenida(String mensajeBienvenida) { this.mensajeBienvenida = mensajeBienvenida; }

    public boolean isSistemaActivo() { return sistemaActivo; }
    public void setSistemaActivo(boolean sistemaActivo) { this.sistemaActivo = sistemaActivo; }

    public boolean isModoMantenimiento() { return modoMantenimiento; }
    public void setModoMantenimiento(boolean modoMantenimiento) { this.modoMantenimiento = modoMantenimiento; }

    public String getMensajeGlobal() { return mensajeGlobal; }
    public void setMensajeGlobal(String mensajeGlobal) { this.mensajeGlobal = mensajeGlobal; }

    public String getBroadcastColor() { return broadcastColor; }
    public void setBroadcastColor(String broadcastColor) { this.broadcastColor = broadcastColor; }

    public boolean isBroadcastActivo() { return broadcastActivo; }
    public void setBroadcastActivo(boolean broadcastActivo) { this.broadcastActivo = broadcastActivo; }

    public int getMinutosParaCierre() { return minutosParaCierre; }
    public void setMinutosParaCierre(int minutosParaCierre) { this.minutosParaCierre = minutosParaCierre; }

    public java.time.LocalDateTime getMantenimientoDesde() { return mantenimientoDesde; }
    public void setMantenimientoDesde(java.time.LocalDateTime mantenimientoDesde) { this.mantenimientoDesde = mantenimientoDesde; }
}
