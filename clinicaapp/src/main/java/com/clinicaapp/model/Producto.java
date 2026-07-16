package com.clinicaapp.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "productos")
public class Producto {
    @Id
    private String id;
    private String nombre;
    private String descripcion;
    private Double precio;
    private Integer stock;
    private String imagenUrl;
    private String categoria;
    private String clinicaId;
    private String lote;
    private String fechaVencimiento;
    private Integer stockMinimo;

    public Producto() {}

    public Producto(String nombre, String descripcion, Double precio, Integer stock, String imagenUrl, String categoria, String clinicaId, String lote, String fechaVencimiento, Integer stockMinimo) {
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.precio = precio;
        this.stock = stock;
        this.imagenUrl = imagenUrl;
        this.categoria = categoria;
        this.clinicaId = clinicaId;
        this.lote = lote;
        this.fechaVencimiento = fechaVencimiento;
        this.stockMinimo = stockMinimo;
    }

    public Producto(String nombre, String descripcion, Double precio, Integer stock, String imagenUrl, String categoria) {
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.precio = precio;
        this.stock = stock;
        this.imagenUrl = imagenUrl;
        this.categoria = categoria;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public Double getPrecio() { return precio; }
    public void setPrecio(Double precio) { this.precio = precio; }

    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }

    public String getImagenUrl() { return imagenUrl; }
    public void setImagenUrl(String imagenUrl) { this.imagenUrl = imagenUrl; }

    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }

    public String getClinicaId() { return clinicaId; }
    public void setClinicaId(String clinicaId) { this.clinicaId = clinicaId; }

    public String getLote() { return lote; }
    public void setLote(String lote) { this.lote = lote; }

    public String getFechaVencimiento() { return fechaVencimiento; }
    public void setFechaVencimiento(String fechaVencimiento) { this.fechaVencimiento = fechaVencimiento; }

    public Integer getStockMinimo() { return stockMinimo != null ? stockMinimo : 5; }
    public void setStockMinimo(Integer stockMinimo) { this.stockMinimo = stockMinimo; }
}
