package com.clinicaapp.repository;

import com.clinicaapp.model.LogNotificacion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface LogNotificacionRepository extends MongoRepository<LogNotificacion, String> {

    @Query("{ $or: [ { 'destinatario': { $regex: ?0, $options: 'i' } }, { 'mensaje': { $regex: ?0, $options: 'i' } }, { 'asunto': { $regex: ?0, $options: 'i' } } ], 'tipo': ?1, 'estado': ?2 }")
    Page<LogNotificacion> buscarLogs(String query, String tipo, String estado, Pageable pageable);

    @Query("{ $or: [ { 'destinatario': { $regex: ?0, $options: 'i' } }, { 'mensaje': { $regex: ?0, $options: 'i' } }, { 'asunto': { $regex: ?0, $options: 'i' } } ], 'tipo': ?1 }")
    Page<LogNotificacion> buscarLogsSinEstado(String query, String tipo, Pageable pageable);

    @Query("{ $or: [ { 'destinatario': { $regex: ?0, $options: 'i' } }, { 'mensaje': { $regex: ?0, $options: 'i' } }, { 'asunto': { $regex: ?0, $options: 'i' } } ], 'estado': ?1 }")
    Page<LogNotificacion> buscarLogsSinTipo(String query, String estado, Pageable pageable);

    @Query("{ $or: [ { 'destinatario': { $regex: ?0, $options: 'i' } }, { 'mensaje': { $regex: ?0, $options: 'i' } }, { 'asunto': { $regex: ?0, $options: 'i' } } ] }")
    Page<LogNotificacion> buscarLogsGeneral(String query, Pageable pageable);

    long countByTipo(String tipo);

    long countByEstado(String estado);
}
