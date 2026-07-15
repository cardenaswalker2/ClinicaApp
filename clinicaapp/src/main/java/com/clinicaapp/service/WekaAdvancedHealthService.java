package com.clinicaapp.service;

import com.clinicaapp.model.Mascota;
import java.util.Map;

public interface WekaAdvancedHealthService {
    Map<String, Object> analizarSaludAvanzada(String mascotaId, Map<String, String> respuestas);
}
