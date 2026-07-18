package com.clinicaapp.repository;

import com.clinicaapp.model.PublicacionAdopcion;
import com.clinicaapp.model.enums.EstadoPublicacion;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PublicacionAdopcionRepository extends MongoRepository<PublicacionAdopcion, String> {

    List<PublicacionAdopcion> findByPropietarioId(String propietarioId);

    Optional<PublicacionAdopcion> findByIdAndPropietarioId(String id, String propietarioId);

    List<PublicacionAdopcion> findByEstado(EstadoPublicacion estado);

    List<PublicacionAdopcion> findByEstadoAndPropietarioId(EstadoPublicacion estado, String propietarioId);
}
