package com.clinicaapp.repository;

import com.clinicaapp.model.AuditoriaSupervision;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AuditoriaSupervisionRepository extends MongoRepository<AuditoriaSupervision, String> {

    List<AuditoriaSupervision> findByUsuarioAfectadoIdOrderByFechaHoraDesc(String usuarioAfectadoId);

    List<AuditoriaSupervision> findByUsuarioAfectadoEmailOrderByFechaHoraDesc(String usuarioAfectadoEmail);

    List<AuditoriaSupervision> findTop30ByOrderByFechaHoraDesc();

    Page<AuditoriaSupervision> findByUsuarioAfectadoId(String usuarioAfectadoId, Pageable pageable);
}
