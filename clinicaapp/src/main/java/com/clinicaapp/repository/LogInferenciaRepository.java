package com.clinicaapp.repository;

import com.clinicaapp.model.LogInferencia;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LogInferenciaRepository extends MongoRepository<LogInferencia, String> {
}
