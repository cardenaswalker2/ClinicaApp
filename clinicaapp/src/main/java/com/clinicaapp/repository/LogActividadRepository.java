package com.clinicaapp.repository;

import com.clinicaapp.model.LogActividad;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LogActividadRepository extends MongoRepository<LogActividad, String> {

    // Obtener las últimas 5 actividades ordenadas por fecha descendente (para el preview del dashboard)
    List<LogActividad> findTop5ByOrderByFechaDesc();

    // Consulta de búsqueda interactiva: combina búsqueda de texto y filtros por módulo/tipo
    @Query("{ " +
           "  '$and': [ " +
           "    { '$or': [ " +
           "      { 'accion': { '$regex': ?0, '$options': 'i' } }, " +
           "      { 'usuario': { '$regex': ?0, '$options': 'i' } }, " +
           "      { 'ip': { '$regex': ?0, '$options': 'i' } }, " +
           "      { 'detalles': { '$regex': ?0, '$options': 'i' } } " +
           "    ] }, " +
           "    { 'modulo': { '$regex': ?1, '$options': 'i' } }, " +
           "    { 'tipo': { '$regex': ?2, '$options': 'i' } } " +
           "  ] " +
           "}")
    Page<LogActividad> searchLogs(String textQuery, String moduloPattern, String tipoPattern, Pageable pageable);
}
