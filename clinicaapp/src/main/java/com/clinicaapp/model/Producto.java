package com.clinicaapp.model;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
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
}
