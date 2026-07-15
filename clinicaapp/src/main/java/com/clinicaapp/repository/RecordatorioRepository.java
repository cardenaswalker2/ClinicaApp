package com.clinicaapp.repository;

import com.clinicaapp.model.Recordatorio;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface RecordatorioRepository extends MongoRepository<Recordatorio, String> {
    List<Recordatorio> findByUsuarioIdOrderByFechaHoraAsc(String usuarioId);
    List<Recordatorio> findByEstadoAndFechaHoraBefore(Recordatorio.EstadoRecordatorio estado, LocalDateTime fechaHora);
}