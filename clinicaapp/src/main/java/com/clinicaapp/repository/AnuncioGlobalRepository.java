package com.clinicaapp.repository;

import com.clinicaapp.model.AnuncioGlobal;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AnuncioGlobalRepository extends MongoRepository<AnuncioGlobal, String> {
    List<AnuncioGlobal> findByActivoTrue();
}
