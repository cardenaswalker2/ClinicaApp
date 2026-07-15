package com.clinicaapp.service;

import com.clinicaapp.model.Producto;
import java.util.List;

public interface IProductoService {
    List<Producto> findAll();
    List<Producto> findByCategoria(String categoria);
    Producto save(Producto producto);
    void deleteById(String id);
}
