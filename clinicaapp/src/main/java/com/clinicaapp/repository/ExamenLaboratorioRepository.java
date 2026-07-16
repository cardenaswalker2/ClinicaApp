package com.clinicaapp.repository;

import com.clinicaapp.model.ExamenLaboratorio;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamenLaboratorioRepository extends MongoRepository<ExamenLaboratorio, String> {
    List<ExamenLaboratorio> findByMascotaId(String mascotaId);
    List<ExamenLaboratorio> findByClinicaId(String clinicaId);
    List<ExamenLaboratorio> findByMascotaIdAndTipoExamenOrderByFechaExamenDesc(String mascotaId, String tipoExamen);
}
