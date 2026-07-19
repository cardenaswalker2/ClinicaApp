package com.clinicaapp.repository;

import com.clinicaapp.model.ModeracionNota;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ModeracionNotaRepository extends MongoRepository<ModeracionNota, String> {
    List<ModeracionNota> findByConversacionIdOrderByFechaHoraDesc(String conversacionId);
}
