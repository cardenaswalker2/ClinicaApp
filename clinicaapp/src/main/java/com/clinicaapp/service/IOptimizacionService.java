package com.clinicaapp.service;

import com.clinicaapp.dto.OptimizacionClinicaResultadoDTO;

public interface IOptimizacionService {

    /**
     * Resuelve el modelo de Programación Lineal Entera Binaria (PLEB)
     * para encontrar la clínica veterinaria óptima más cercana a la ubicación del usuario,
     * garantizando:
     * 1. No negatividad (distancia Haversine >= 0).
     * 2. Cumplimiento de radio máximo de cobertura (di * Xi <= Dmax).
     * 3. Cumplimiento de disponibilidad/operatividad (Xi <= Ai).
     * 4. Selección única binaria (Sum(Xi) = 1, Xi in {0,1}).
     *
     * @param latitudUsuario Latitud del usuario
     * @param longitudUsuario Longitud del usuario
     * @param radioMaxKm Radio máximo de búsqueda en kilómetros (ej: 15.0)
     * @param direccionUsuario Dirección textual opcional
     * @return DTO estructurado con la clínica ganadora y todo el desglose matemático
     */
    OptimizacionClinicaResultadoDTO resolverOptimizacion(double latitudUsuario, double longitudUsuario, double radioMaxKm, String direccionUsuario);

    /**
     * Calcula la distancia geodésica mediante la fórmula de Haversine entre dos puntos (en km).
     * Garantiza siempre un resultado no negativo (d >= 0).
     */
    double calcularDistanciaHaversine(double lat1, double lon1, double lat2, double lon2);
}
