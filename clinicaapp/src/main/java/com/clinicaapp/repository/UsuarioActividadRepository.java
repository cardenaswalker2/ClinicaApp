package com.clinicaapp.repository;

import com.clinicaapp.model.UsuarioActividad;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UsuarioActividadRepository extends MongoRepository<UsuarioActividad, String> {

    List<UsuarioActividad> findByUsuarioIdOrderByFechaHoraDesc(String usuarioId);

    List<UsuarioActividad> findByEmailOrderByFechaHoraDesc(String email);

    List<UsuarioActividad> findTop20ByUsuarioIdOrderByFechaHoraDesc(String usuarioId);

    List<UsuarioActividad> findTop20ByEmailOrderByFechaHoraDesc(String email);

    Page<UsuarioActividad> findByUsuarioId(String usuarioId, Pageable pageable);

    Page<UsuarioActividad> findByEmail(String email, Pageable pageable);
}
