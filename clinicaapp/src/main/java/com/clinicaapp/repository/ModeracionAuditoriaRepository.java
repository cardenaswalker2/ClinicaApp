package com.clinicaapp.repository;

import com.clinicaapp.model.ModeracionAuditoria;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ModeracionAuditoriaRepository extends MongoRepository<ModeracionAuditoria, String> {
    List<ModeracionAuditoria> findByConversacionIdOrderByFechaHoraDesc(String conversacionId);
}
