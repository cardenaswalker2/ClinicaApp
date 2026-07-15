package com.clinicaapp.service.impl;

import org.springframework.stereotype.Service;
import weka.core.Attribute;
import weka.core.DenseInstance;
import weka.core.Instances;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

@Service
public class WekaAdvancedDataGenerator {

    private final Random random = new Random();

    public Instances generarDatosEntrenamiento(int numInstancias) {
        ArrayList<Attribute> attributes = new ArrayList<>();

        // 1. Atributos Biométricos
        attributes.add(new Attribute("edad"));
        List<String> tamaños = Arrays.asList("PEQUENO", "MEDIANO", "GRANDE", "GIGANTE");
        attributes.add(new Attribute("tamano", tamaños));
        List<String> pesos = Arrays.asList("BAJO", "NORMAL", "SOBREPESO");
        attributes.add(new Attribute("peso", pesos));

        // 2. Atributos de Comportamiento (Inputs del Cuestionario)
        List<String> nivelesEnergia = Arrays.asList("ALTA", "NORMAL", "BAJA");
        attributes.add(new Attribute("nivel_energia", nivelesEnergia));

        List<String> movilidades = Arrays.asList("FLUIDA", "LEVE_RIGIDEZ", "DIFICULTAD_MARCADA");
        attributes.add(new Attribute("movilidad", movilidades));

        List<String> apetitos = Arrays.asList("AUMENTADO", "NORMAL", "DISMINUIDO");
        attributes.add(new Attribute("apetito", apetitos));

        List<String> sed = Arrays.asList("NORMAL", "EXCESIVA");
        attributes.add(new Attribute("sed", sed));

        // 3. Clase: Estado de Salud General (Output)
        List<String> estadosSalud = Arrays.asList("EXCELENTE", "PREVENTIVO", "CRITICO");
        Attribute claseEstado = new Attribute("estado_salud", estadosSalud);
        attributes.add(claseEstado);

        Instances dataset = new Instances("AdvancedHealthDataset", attributes, numInstancias);
        dataset.setClassIndex(dataset.numAttributes() - 1);

        for (int i = 0; i < numInstancias; i++) {
            DenseInstance instance = new DenseInstance(dataset.numAttributes());
            
            int edad = random.nextInt(16) + 1;
            String tamano = tamaños.get(random.nextInt(tamaños.size()));
            String peso = pesos.get(random.nextInt(pesos.size()));
            String energia = nivelesEnergia.get(random.nextInt(nivelesEnergia.size()));
            String movilidad = movilidades.get(random.nextInt(movilidades.size()));
            String apetito = apetitos.get(random.nextInt(apetitos.size()));
            String sedVal = sed.get(random.nextInt(sed.size()));

            instance.setValue(attributes.get(0), edad);
            instance.setValue(attributes.get(1), tamano);
            instance.setValue(attributes.get(2), peso);
            instance.setValue(attributes.get(3), energia);
            instance.setValue(attributes.get(4), movilidad);
            instance.setValue(attributes.get(5), apetito);
            instance.setValue(attributes.get(6), sedVal);

            // Lógica de entrenamiento (Reglas de Negocio Veterinarias)
            String estado = "PREVENTIVO";

            // Casos Críticos
            if (movilidad.equals("DIFICULTAD_MARCADA") || (edad > 10 && movilidad.equals("LEVE_RIGIDEZ"))) {
                estado = "CRITICO";
            } else if (sedVal.equals("EXCESIVA") && apetito.equals("DISMINUIDO")) {
                estado = "CRITICO";
            } else if (peso.equals("SOBREPESO") && tamano.equals("GRANDE") && edad > 7) {
                estado = "CRITICO";
            }
            // Casos Excelentes
            else if (edad < 5 && movilidad.equals("FLUIDA") && energia.equals("ALTA") && peso.equals("NORMAL")) {
                estado = "EXCELENTE";
            } else if (movilidad.equals("FLUIDA") && apetito.equals("NORMAL") && energia.equals("NORMAL")) {
                estado = "EXCELENTE";
            }

            // Ruido (3%)
            if (random.nextInt(100) < 3) {
                estado = estadosSalud.get(random.nextInt(estadosSalud.size()));
            }

            instance.setValue(claseEstado, estado);
            dataset.add(instance);
        }

        return dataset;
    }
}
