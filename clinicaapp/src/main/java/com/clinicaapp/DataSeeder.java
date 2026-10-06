package com.clinicaapp;

import com.clinicaapp.model.Clinica;
import com.clinicaapp.model.Producto;
import com.clinicaapp.model.enums.EstadoClinica;
import com.clinicaapp.repository.ClinicaRepository;
import com.clinicaapp.repository.ProductoRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;
import java.util.List;

@Configuration
public class DataSeeder {

    @Bean
    CommandLineRunner initDatabase(ProductoRepository repository, ClinicaRepository clinicaRepository) {
        return args -> {
            // 1. Sembrado de Productos
            if (repository.count() == 0) {
                repository.save(new Producto("Comida Premium Perro", "Alimento balanceado para perros adultos de raza grande.", 85000.0, 50, "https://img.freepik.com/free-photo/dry-pet-food-bowl-isolated-white-background_123827-23429.jpg", "Comida"));
                repository.save(new Producto("Juguete Mordedor", "Hueso de caucho resistente para limpieza dental.", 15000.0, 100, "https://img.freepik.com/free-photo/dog-toy-isolated-white_123827-23403.jpg", "Juguetes"));
                repository.save(new Producto("Shampoo Antipulgas", "Fórmula suave para pieles sensibles con aroma a lavanda.", 25000.0, 30, "https://img.freepik.com/free-photo/shampoo-bottle-isolated_123827-23450.jpg", "Aseo"));
                repository.save(new Producto("Vitaminas Multiviral", "Suplemento vitamínico para el sistema inmune.", 45000.0, 20, "https://img.freepik.com/free-photo/pills-bottle-isolated_123827-23460.jpg", "Salud"));
                repository.save(new Producto("Pelota Interactiva", "Pelota con luces y sonidos para estimular el juego.", 35000.0, 40, "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?auto=format&fit=crop&q=80&w=400", "Juguetes"));
                repository.save(new Producto("Snacks de Pollo", "Premios 100% naturales deshidratados.", 12000.0, 200, "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&q=80&w=400", "Comida"));
                repository.save(new Producto("Collar Reflejante", "Ajustable y con material reflectante para paseos nocturnos.", 28000.0, 60, "https://images.unsplash.com/photo-1591768793355-74d7af236c1f?auto=format&fit=crop&q=80&w=400", "Accesorios"));
                repository.save(new Producto("Cama Ortopédica", "Cama con espuma de memoria para mascotas senior.", 120000.0, 10, "https://images.unsplash.com/photo-1591769225440-811ad7d6eca3?auto=format&fit=crop&q=80&w=400", "Hogar"));
                repository.save(new Producto("Arena Sanitaria", "Arena aglutinante con control de olores.", 30000.0, 50, "https://images.unsplash.com/photo-1589802829985-8137510344d8?auto=format&fit=crop&q=80&w=400", "Hogar"));
                repository.save(new Producto("Cepillo de Cerdas", "Cepillo ergonómico para el cuidado del pelaje.", 18000.0, 40, "https://images.unsplash.com/photo-1581888227599-779811939961?auto=format&fit=crop&q=80&w=400", "Aseo"));
                System.out.println("Base de datos de productos sembrada exitosamente.");
            }

            // 2. Sembrado de Clínicas Georreferenciadas de Cartagena (para Investigación de Operaciones)
            if (clinicaRepository.count() == 0) {
                Clinica c1 = new Clinica();
                c1.setNombre("Centro Veterinario San Roque - Manga");
                c1.setDireccion("Calle Real de Manga #24-58, Cartagena");
                c1.setTelefono("+57 300 123 4567");
                c1.setEmail("manga@sanroquevet.com");
                c1.setDescripcion("Atención veterinaria integral 24 horas, quirófano especializado y laboratorio clínico.");
                c1.setImagenUrl("https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&q=80&w=800");
                c1.setLatitud(10.4075);
                c1.setLongitud(-75.5385);
                c1.setEstado(EstadoClinica.APROBADA);
                c1.setHoraApertura("07:00");
                c1.setHoraCierre("22:00");
                c1.setServiciosOfrecidos(Arrays.asList("Consulta General", "Vacunación", "Cirugía", "Urgencias 24h"));
                clinicaRepository.save(c1);

                Clinica c2 = new Clinica();
                c2.setNombre("Clínica Veterinaria Bocagrande Pets");
                c2.setDireccion("Av. San Martín Cra 2da #8-40, Bocagrande, Cartagena");
                c2.setTelefono("+57 315 987 6543");
                c2.setEmail("info@bocagrandepets.com");
                c2.setDescripcion("Especialistas en dermatología felina y canina, ecografías y cuidados intensivos.");
                c2.setImagenUrl("https://images.unsplash.com/photo-1628009368231-7bb7cfcb0def?auto=format&fit=crop&q=80&w=800");
                c2.setLatitud(10.3995);
                c2.setLongitud(-75.5560);
                c2.setEstado(EstadoClinica.APROBADA);
                c2.setHoraApertura("08:00");
                c2.setHoraCierre("20:00");
                c2.setServiciosOfrecidos(Arrays.asList("Consulta Especializada", "Ecografía", "Grooming Premium"));
                clinicaRepository.save(c2);

                Clinica c3 = new Clinica();
                c3.setNombre("Hospital Veterinario del Norte - Crespo");
                c3.setDireccion("Calle 70 #4-25, Crespo, Cartagena");
                c3.setTelefono("+57 320 555 7890");
                c3.setEmail("contacto@vetnortecrespo.com");
                c3.setDescripcion("Hospitalización 24/7, rayos X digitales y unidad de cuidados postanestésicos.");
                c3.setImagenUrl("https://images.unsplash.com/photo-1576201836106-db1758fd1c97?auto=format&fit=crop&q=80&w=800");
                c3.setLatitud(10.4480);
                c3.setLongitud(-75.5180);
                c3.setEstado(EstadoClinica.APROBADA);
                c3.setHoraApertura("00:00");
                c3.setHoraCierre("23:59");
                c3.setServiciosOfrecidos(Arrays.asList("Hospitalización", "Rayos X", "Cirugía Ortopédica", "Urgencias 24h"));
                clinicaRepository.save(c3);

                Clinica c4 = new Clinica();
                c4.setNombre("Animal Care Providencia");
                c4.setDireccion("Diag. 32 #71-89, Barrio Providencia, Cartagena");
                c4.setTelefono("+57 311 444 3322");
                c4.setEmail("providencia@animalcare.com");
                c4.setDescripcion("Medicina preventiva, vacunación y desparasitación con altos estándares de calidad.");
                c4.setImagenUrl("https://images.unsplash.com/photo-1599443015574-be5fe8a05783?auto=format&fit=crop&q=80&w=800");
                c4.setLatitud(10.3850);
                c4.setLongitud(-75.4750);
                c4.setEstado(EstadoClinica.APROBADA);
                c4.setHoraApertura("08:00");
                c4.setHoraCierre("18:00");
                c4.setServiciosOfrecidos(Arrays.asList("Consulta General", "Vacunación", "Odontología"));
                clinicaRepository.save(c4);

                Clinica c5 = new Clinica();
                c5.setNombre("Veterinaria del Caribe - Pie de la Popa");
                c5.setDireccion("Calle 30 #21-105, Pie de la Popa, Cartagena");
                c5.setTelefono("+57 304 888 9911");
                c5.setEmail("piedelapopa@vetcaribe.com");
                c5.setDescripcion("Centro médico veterinario con énfasis en nutrición y rehabilitación física animal.");
                c5.setImagenUrl("https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&q=80&w=800");
                c5.setLatitud(10.4180);
                c5.setLongitud(-75.5310);
                c5.setEstado(EstadoClinica.APROBADA);
                c5.setHoraApertura("08:30");
                c5.setHoraCierre("19:00");
                c5.setServiciosOfrecidos(Arrays.asList("Consulta General", "Rehabilitación", "Nutrición"));
                clinicaRepository.save(c5);

                System.out.println("Base de datos de clínicas georreferenciadas sembrada exitosamente.");
            } else {
                // Si ya existen clínicas pero alguna tiene coordenadas en 0.0, actualizarlas
                List<Clinica> clinicas = clinicaRepository.findAll();
                boolean actualizadas = false;
                for (Clinica c : clinicas) {
                    if (c.getLatitud() == 0.0 || c.getLongitud() == 0.0) {
                        if (c.getNombre() != null && c.getNombre().toLowerCase().contains("manga")) {
                            c.setLatitud(10.4075);
                            c.setLongitud(-75.5385);
                        } else if (c.getNombre() != null && c.getNombre().toLowerCase().contains("bocagrande")) {
                            c.setLatitud(10.3995);
                            c.setLongitud(-75.5560);
                        } else if (c.getNombre() != null && c.getNombre().toLowerCase().contains("crespo")) {
                            c.setLatitud(10.4480);
                            c.setLongitud(-75.5180);
                        } else {
                            // Coordenadas por defecto en Cartagena
                            c.setLatitud(10.3910 + (Math.random() * 0.04 - 0.02));
                            c.setLongitud(-75.4794 + (Math.random() * 0.04 - 0.02));
                        }
                        clinicaRepository.save(c);
                        actualizadas = true;
                    }
                }
                if (actualizadas) {
                    System.out.println("Coordenadas de clínicas existentes actualizadas correctamente.");
                }
            }
        };
    }
}
