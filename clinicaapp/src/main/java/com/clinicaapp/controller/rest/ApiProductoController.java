package com.clinicaapp.controller.rest;

import com.clinicaapp.model.Producto;
import com.clinicaapp.service.IProductoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/productos")
public class ApiProductoController {

    @Autowired
    private IProductoService productoService;

    @GetMapping
    public List<Producto> getAll() {
        return productoService.findAll();
    }

    @GetMapping("/categoria/{categoria}")
    public List<Producto> getByCategoria(@PathVariable String categoria) {
        return productoService.findByCategoria(categoria);
    }

    @PostMapping
    public Producto save(@RequestBody Producto producto) {
        return productoService.save(producto);
    }
}
