package com.clinicaapp.repository;

import com.clinicaapp.model.MensajeDirecto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MensajeDirectoRepository extends MongoRepository<MensajeDirecto, String> {

    List<MensajeDirecto> findByDestinatarioIdOrderByFechaEnvioDesc(String destinatarioId);

    List<MensajeDirecto> findByDestinatarioEmailOrderByFechaEnvioDesc(String destinatarioEmail);

    List<MensajeDirecto> findByRemitenteEmailOrderByFechaEnvioDesc(String remitenteEmail);

    List<MensajeDirecto> findByDestinatarioEmailAndLeidoFalseOrderByFechaEnvioDesc(String destinatarioEmail);

    long countByDestinatarioEmailAndLeidoFalse(String destinatarioEmail);

    Page<MensajeDirecto> findByDestinatarioId(String destinatarioId, Pageable pageable);

    Page<MensajeDirecto> findByDestinatarioEmail(String destinatarioEmail, Pageable pageable);

    List<MensajeDirecto> findTop50ByOrderByFechaEnvioDesc();

    // Hilo de conversación bi-direccional por ID de usuario o Correo
    List<MensajeDirecto> findByConversacionUsuarioIdOrderByFechaEnvioAsc(String conversacionUsuarioId);

    List<MensajeDirecto> findByDestinatarioEmailOrRemitenteEmailOrderByFechaEnvioAsc(String email1, String email2);
}
