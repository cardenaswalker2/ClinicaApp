package com.clinicaapp.service.impl;

import com.clinicaapp.model.Producto;
import com.clinicaapp.repository.ProductoRepository;
import com.clinicaapp.service.IProductoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ProductoServiceImpl implements IProductoService {

    @Autowired
    private ProductoRepository productoRepository;

    @Override
    public List<Producto> findAll() {
        return productoRepository.findAll();
    }

    @Override
    public List<Producto> findByCategoria(String categoria) {
        return productoRepository.findByCategoria(categoria);
    }

    @Override
    public Producto save(Producto producto) {
        return productoRepository.save(producto);
    }

    @Override
    public void deleteById(String id) {
        productoRepository.deleteById(id);
    }
}
