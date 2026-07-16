package com.clinicaapp.repository;

import com.clinicaapp.model.Producto;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface ProductoRepository extends MongoRepository<Producto, String> {
    List<Producto> findByCategoria(String categoria);
    List<Producto> findByNombreContainingIgnoreCase(String nombre);
    List<Producto> findByClinicaId(String clinicaId);
    List<Producto> findByClinicaIdAndCategoria(String clinicaId, String categoria);
}
