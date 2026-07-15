package com.clinicaapp.service.impl;

import com.clinicaapp.model.Mascota;
import com.clinicaapp.model.enums.Especie;
import com.clinicaapp.service.IMascotaService;
import com.clinicaapp.service.WekaAdvancedHealthService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import weka.classifiers.trees.J48;
import weka.core.Attribute;
import weka.core.DenseInstance;
import weka.core.Instances;
import weka.core.SerializationHelper;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

@Service
public class WekaAdvancedHealthServiceImpl implements WekaAdvancedHealthService {

    private static final String MODEL_PATH = "health_advanced.model";
    private J48 classifier;
    private Instances structure;

    @Autowired
    private WekaAdvancedDataGenerator dataGenerator;

    @Autowired
    private IMascotaService mascotaService;

    @PostConstruct
    public void init() {
        try {
            File modelFile = new File(MODEL_PATH);
            if (modelFile.exists()) {
                Object[] data = (Object[]) SerializationHelper.readAll(MODEL_PATH);
                classifier = (J48) data[0];
                structure = (Instances) data[1];
            } else {
                Instances dataset = dataGenerator.generarDatosEntrenamiento(1500);
                classifier = new J48();
                classifier.buildClassifier(dataset);
                structure = new Instances(dataset, 0);
                SerializationHelper.writeAll(MODEL_PATH, new Object[]{classifier, structure});
            }
        } catch (Exception e) {
            System.err.println("❌ Error initializing Advanced Weka: " + e.getMessage());
        }
    }

    @Override
    public Map<String, Object> analizarSaludAvanzada(String mascotaId, Map<String, String> respuestas) {
        Map<String, Object> resultado = new HashMap<>();
        
        Mascota mascota = mascotaService.findById(mascotaId).orElse(null);
        if (mascota == null || classifier == null) {
            resultado.put("error", "Mascota no encontrada o IA no disponible");
            return resultado;
        }

        try {
            DenseInstance instance = new DenseInstance(structure.numAttributes());
            instance.setDataset(structure);

            // 1. Datos Biométricos
            instance.setValue(structure.attribute("edad"), mascota.getEdad());
            
            String tamano = "MEDIANO";
            if (mascota.getEspecie() == Especie.PERRO) {
                String raza = mascota.getRaza() != null ? mascota.getRaza().toUpperCase() : "";
                if (raza.contains("GRANDE") || raza.contains("PASTOR") || raza.contains("GOLDEN")) tamano = "GRANDE";
                else if (raza.contains("PEQUEÑO") || raza.contains("CHIHUAHUA")) tamano = "PEQUENO";
            } else {
                tamano = "PEQUENO";
            }
            instance.setValue(structure.attribute("tamano"), tamano);
            instance.setValue(structure.attribute("peso"), "NORMAL"); // Default, se podría mejorar

            // 2. Datos del Cuestionario
            setValueIfPresent(instance, "nivel_energia", respuestas.get("energia"));
            setValueIfPresent(instance, "movilidad", respuestas.get("movilidad"));
            setValueIfPresent(instance, "apetito", respuestas.get("apetito"));
            setValueIfPresent(instance, "sed", respuestas.get("sed"));

            double resultIndex = classifier.classifyInstance(instance);
            String estadoFinal = structure.classAttribute().value((int) resultIndex);
            double[] distribution = classifier.distributionForInstance(instance);

            resultado.put("status", estadoFinal);
            resultado.put("confidence", distribution[(int) resultIndex] * 100);
            resultado.put("mascotaNombre", mascota.getNombre());
            
            // Recomendaciones basadas en el estado
            resultado.put("recomendaciones", getRecomendaciones(estadoFinal, respuestas));
            
            // Metadatos para la UI
            resultado.put("color", getColorForStatus(estadoFinal));
            resultado.put("icon", getIconForStatus(estadoFinal));

        } catch (Exception e) {
            resultado.put("error", "Error en el procesamiento: " + e.getMessage());
        }

        return resultado;
    }

    private void setValueIfPresent(DenseInstance instance, String attrName, String value) {
        Attribute attr = structure.attribute(attrName);
        if (value != null && attr.indexOfValue(value.toUpperCase()) != -1) {
            instance.setValue(attr, value.toUpperCase());
        } else {
            instance.setValue(attr, attr.value(1)); // Default a la mitad
        }
    }

    private String getRecomendaciones(String status, Map<String, String> respuestas) {
        if ("CRITICO".equals(status)) {
            return "Se recomienda una consulta veterinaria urgente. La combinación de factores indica una posible patología en curso.";
        } else if ("PREVENTIVO".equals(status)) {
            return "Tu mascota está estable, pero presenta signos que requieren atención preventiva, especialmente en " + 
                   (respuestas.get("movilidad").contains("DIFICULTAD") ? "sus articulaciones." : "su metabolismo.");
        } else {
            return "¡Excelente estado! Sigue manteniendo su dieta y nivel de actividad actual. No olvides su chequeo anual.";
        }
    }

    private String getColorForStatus(String status) {
        switch (status) {
            case "CRITICO": return "#ef4444";
            case "PREVENTIVO": return "#f59e0b";
            case "EXCELENTE": return "#10b981";
            default: return "#6366f1";
        }
    }

    private String getIconForStatus(String status) {
        switch (status) {
            case "CRITICO": return "bi-exclamation-triangle-fill";
            case "PREVENTIVO": return "bi-shield-shaded";
            case "EXCELENTE": return "bi-check-circle-fill";
            default: return "bi-robot";
        }
    }
}
