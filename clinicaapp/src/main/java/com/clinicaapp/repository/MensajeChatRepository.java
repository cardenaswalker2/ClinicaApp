package com.clinicaapp.repository;

import com.clinicaapp.model.MensajeChat;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MensajeChatRepository extends MongoRepository<MensajeChat, String> {

    List<MensajeChat> findByAdopcionId(String adopcionId);

    List<MensajeChat> findByEmisorIdOrReceptorId(String emisorId, String receptorId);

    List<MensajeChat> findByAdopcionIdAndEmisorIdAndReceptorId(String adopcionId, String emisorId, String receptorId);
    
    List<MensajeChat> findByAdopcionIdAndReceptorIdAndEmisorId(String adopcionId, String receptorId, String emisorId);
    
    long countByReceptorIdAndLeido(String receptorId, boolean leido);
}
