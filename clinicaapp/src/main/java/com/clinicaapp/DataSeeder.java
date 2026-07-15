package com.clinicaapp;

import com.clinicaapp.model.Producto;
import com.clinicaapp.repository.ProductoRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataSeeder {

    @Bean
    CommandLineRunner initDatabase(ProductoRepository repository) {
        return args -> {
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
        };
    }
}
