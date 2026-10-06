package com.clinicaapp.service.impl;

import com.clinicaapp.dto.OptimizacionClinicaResultadoDTO;
import com.clinicaapp.dto.OptimizacionClinicaResultadoDTO.ClinicaOptimaDTO;
import com.clinicaapp.dto.OptimizacionClinicaResultadoDTO.VariableClinicaDTO;
import com.clinicaapp.model.Clinica;
import com.clinicaapp.model.enums.EstadoClinica;
import com.clinicaapp.repository.ClinicaRepository;
import com.clinicaapp.service.IOptimizacionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

@Service
public class OptimizacionServiceImpl implements IOptimizacionService {

    private static final Logger log = LoggerFactory.getLogger(OptimizacionServiceImpl.class);

    // Radio medio de la Tierra en kilómetros para la fórmula de Haversine
    private static final double RADIO_TIERRA_KM = 6371.0;

    @Autowired
    private ClinicaRepository clinicaRepository;

    @Override
    public OptimizacionClinicaResultadoDTO resolverOptimizacion(double latitudUsuario, double longitudUsuario, double radioMaxKm, String direccionUsuario) {
        OptimizacionClinicaResultadoDTO resultado = new OptimizacionClinicaResultadoDTO();
        resultado.setUserLat(latitudUsuario);
        resultado.setUserLng(longitudUsuario);
        resultado.setUserAddress(direccionUsuario != null && !direccionUsuario.trim().isEmpty() ? direccionUsuario : "Ubicación detectada por GPS");
        resultado.setRadioMaxKm(radioMaxKm > 0 ? radioMaxKm : 15.0);

        // 1. Obtener todas las clínicas registradas en el sistema
        List<Clinica> todasLasClinicas = clinicaRepository.findAll();
        resultado.setTotalClinicasEvaluadas(todasLasClinicas.size());

        List<VariableClinicaDTO> variables = new ArrayList<>();
        List<String> restricciones = new ArrayList<>();
        StringBuilder foBuilder = new StringBuilder("Min Z = ");

        int index = 1;
        int factiblesCount = 0;
        int descartadasRadio = 0;
        int descartadasDisponibilidad = 0;

        Clinica mejorClinica = null;
        double menorDistancia = Double.MAX_VALUE;
        VariableClinicaDTO variableGanadora = null;

        for (Clinica clinica : todasLasClinicas) {
            String varName = "X" + index;

            // 2. Coordenadas de la clínica (fallback a centro de Cartagena si no tiene configuradas)
            double clinicaLat = clinica.getLatitud() != 0.0 ? clinica.getLatitud() : 10.3910;
            double clinicaLng = clinica.getLongitud() != 0.0 ? clinica.getLongitud() : -75.4794;

            // 3. Cálculo de Distancia mediante Haversine (Garantía de No Negatividad d_i >= 0)
            double distancia = calcularDistanciaHaversine(latitudUsuario, longitudUsuario, clinicaLat, clinicaLng);
            distancia = redondear(distancia, 2);

            // 4. Parámetro de Disponibilidad A_i (1 si está APROBADA, 0 si PENDIENTE o RECHAZADA)
            boolean disponible = (clinica.getEstado() == EstadoClinica.APROBADA);
            int valorAi = disponible ? 1 : 0;

            // 5. Evaluación de Restricciones del Modelo
            boolean cumpleRadio = distancia <= resultado.getRadioMaxKm();
            boolean esFactible = disponible && cumpleRadio;

            String motivoDescarte = null;
            if (!disponible) {
                motivoDescarte = "No operativa (Estado: " + clinica.getEstado() + ", A_" + index + " = 0)";
                descartadasDisponibilidad++;
            } else if (!cumpleRadio) {
                motivoDescarte = "Excede radio máximo (" + distancia + " km > " + resultado.getRadioMaxKm() + " km)";
                descartadasRadio++;
            } else {
                factiblesCount++;
            }

            // Construir representación matemática de la variable
            VariableClinicaDTO varDto = new VariableClinicaDTO(
                    varName,
                    clinica.getId(),
                    clinica.getNombre(),
                    clinica.getDireccion() != null ? clinica.getDireccion() : "Cartagena, Bolívar",
                    clinicaLat,
                    clinicaLng,
                    distancia,
                    disponible,
                    cumpleRadio,
                    esFactible,
                    0, // Se actualizará a 1 si resulta seleccionada
                    motivoDescarte
            );

            variables.add(varDto);

            // Armar parte de la Función Objetivo: ... + d_i * X_i
            if (index > 1) {
                foBuilder.append(" + ");
            }
            foBuilder.append(distancia).append("·").append(varName);

            // Armar Restricción de disponibilidad: X_i <= A_i
            restricciones.add(varName + " ≤ " + valorAi + "  (Disponibilidad: " + clinica.getNombre() + ")");
            // Armar Restricción de distancia máxima: d_i · X_i <= D_max
            restricciones.add(distancia + "·" + varName + " ≤ " + resultado.getRadioMaxKm() + " km  (Radio de cobertura)");

            // 6. Optimización (Búsqueda del mínimo sobre el espacio factible)
            if (esFactible && distancia < menorDistancia) {
                menorDistancia = distancia;
                mejorClinica = clinica;
                variableGanadora = varDto;
            }

            index++;
        }

        // Restricción de selección única: X1 + X2 + ... + Xn = 1
        StringBuilder seleccionUnica = new StringBuilder();
        for (int i = 1; i <= variables.size(); i++) {
            if (i > 1) seleccionUnica.append(" + ");
            seleccionUnica.append("X").append(i);
        }
        seleccionUnica.append(" = 1  (Seleccionar exactamente una clínica)");
        restricciones.add(0, seleccionUnica.toString());

        // Restricción de no negatividad / binariedad
        restricciones.add("X_i ∈ {0, 1}, ∀ i ∈ {1, ..., " + variables.size() + "}  (Variables Binarias)");
        restricciones.add("d_i ≥ 0, ∀ i  (Condición de No Negatividad en Distancias)");

        resultado.setFuncionObjetivoFormula(foBuilder.toString());
        resultado.setRestricciones(restricciones);
        resultado.setVariablesDecision(variables);
        resultado.setClinicasFactibles(factiblesCount);
        resultado.setClinicasDescartadasPorRadio(descartadasRadio);
        resultado.setClinicasDescartadasPorDisponibilidad(descartadasDisponibilidad);

        // 7. Establecer Solución Óptima
        if (variableGanadora != null && mejorClinica != null) {
            variableGanadora.setValorOptimo(1); // X_k = 1
            resultado.setSolucionEncontrada(true);
            resultado.setDistanciaMinimaKm(menorDistancia);

            ClinicaOptimaDTO clinicaOptima = new ClinicaOptimaDTO();
            clinicaOptima.setId(mejorClinica.getId());
            clinicaOptima.setNombre(mejorClinica.getNombre());
            clinicaOptima.setDireccion(mejorClinica.getDireccion());
            clinicaOptima.setTelefono(mejorClinica.getTelefono());
            clinicaOptima.setEmail(mejorClinica.getEmail());
            clinicaOptima.setDescripcion(mejorClinica.getDescripcion());
            clinicaOptima.setImagenUrl(mejorClinica.getImagenUrl());
            clinicaOptima.setLatitud(variableGanadora.getLatitud());
            clinicaOptima.setLongitud(variableGanadora.getLongitud());
            clinicaOptima.setDistanciaKm(menorDistancia);
            clinicaOptima.setHorarioAtencion(mejorClinica.getHoraApertura() + " - " + mejorClinica.getHoraCierre());

            resultado.setClinicaSeleccionada(clinicaOptima);
            resultado.setMensaje("Solución óptima encontrada exitosamente: " + mejorClinica.getNombre() + " a " + menorDistancia + " km.");
        } else {
            resultado.setSolucionEncontrada(false);
            resultado.setDistanciaMinimaKm(0.0);
            resultado.setMensaje("No se encontraron clínicas factibles que cumplan con el radio de " + resultado.getRadioMaxKm() + " km y estén disponibles.");
        }

        return resultado;
    }

    /**
     * Implementación rigurosa de la Fórmula del Semiverseno (Haversine).
     * Calcula la distancia sobre una esfera dada latitud y longitud en grados decimales.
     * Resultado siempre >= 0.
     */
    @Override
    public double calcularDistanciaHaversine(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double lat1Rad = Math.toRadians(lat1);
        double lat2Rad = Math.toRadians(lat2);

        // a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlon/2)
        double a = Math.sin(dLat / 2.0) * Math.sin(dLat / 2.0) +
                   Math.cos(lat1Rad) * Math.cos(lat2Rad) *
                   Math.sin(dLon / 2.0) * Math.sin(dLon / 2.0);

        // c = 2 * atan2(√a, √(1−a))
        double c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a));

        // d = R * c (siempre no negativo)
        double distancia = RADIO_TIERRA_KM * c;
        return Math.max(0.0, distancia);
    }

    private double redondear(double valor, int decimales) {
        if (Double.isNaN(valor) || Double.isInfinite(valor)) return 0.0;
        BigDecimal bd = BigDecimal.valueOf(valor);
        bd = bd.setScale(decimales, RoundingMode.HALF_UP);
        return bd.doubleValue();
    }
}
