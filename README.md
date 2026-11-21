# ClinicaApp — Sistema Integral de Gestión de Clínicas Veterinarias

Proyecto de Aula Interdisciplinario (VII Semestre de Ingeniería de Sistemas).  
Repositorio oficial: [https://github.com/cardenaswalker2/ClinicaApp](https://github.com/cardenaswalker2/ClinicaApp)

---

## Descripción del Proyecto

**ClinicaApp** es una plataforma web (y cliente móvil complementario) orientada a la gestión integral de clínicas veterinarias. Integra:

1. **Desarrollo Web Avanzado:** Aplicación backend y web en Spring Boot 3 con arquitectura por capas, autenticación tradicional y OAuth2 (Google / GitHub), gestión de citas, historias clínicas, pagos con Stripe, notificaciones por correo y SMS (Twilio), generación de reportes PDF, analítica predictiva con Weka y asistente inteligente integrado mediante LLM (Groq API).
2. **Visualización de Datos II:** Modelo dimensional, Data Warehouse y dashboard interactivo en Power BI conectado a la información del sistema.
3. **Investigación de Operaciones:** Modelo matemático de optimización para la toma de decisiones operativas dentro de la clínica.

---

## Stack Tecnológico

* **Backend & Web:** Java 17, Spring Boot 3.2.1, Spring Web, Spring Security, Spring OAuth2 Client, Thymeleaf, Lombok.
* **Base de Datos:** MongoDB (`spring-boot-starter-data-mongodb`).
* **Inteligencia Artificial & ML:** Groq API (`openai/gpt-oss-20b` vía REST) y Weka (`weka-stable` 3.8.6) para modelos predictivos (`.model` / `.arff`).
* **Servicios Externos:** Stripe (pagos), Twilio (SMS), Gmail SMTP (correos), OpenHTMLToPDF (reportes PDF).
* **Cliente Móvil:** Flutter / Dart (`clinicaapp_mobile/`).
* **Contenedores / Despliegue:** Docker (`Dockerfile`), Nixpacks (`nixpacks.toml`).

---

## Estructura del Repositorio

```text
ClinicaApp/
├── clinicaapp/                     # Aplicación principal Spring Boot
│   ├── src/main/java/com/clinicaapp/
│   │   ├── config/                 # Configuraciones (Security, OAuth2, etc.)
│   │   ├── controller/             # Controladores Web (Thymeleaf) y REST
│   │   ├── dto/                    # Objetos de Transferencia de Datos
│   │   ├── model/                  # Entidades / Documentos de MongoDB
│   │   ├── repository/             # Repositorios Spring Data MongoDB
│   │   ├── service/                # Lógica de negocio e integraciones (Groq, Weka, Stripe, Twilio)
│   │   ├── setup/                  # Inicialización del sistema
│   │   ├── task/                   # Tareas programadas
│   │   ├── ClinicaappApplication.java
│   │   └── DataSeeder.java         # Carga inicial de datos de prueba
│   ├── src/main/resources/
│   │   ├── templates/              # Vistas HTML (Thymeleaf)
│   │   ├── static/                 # Recursos estáticos (CSS, JS, imágenes)
│   │   └── application.properties.example
│   ├── Dockerfile
│   └── pom.xml
├── clinicaapp_mobile/              # Aplicación móvil en Flutter
├── docs/                           # Documentación, evidencias y Data Warehouse Power BI
└── README.md
```

---

## Requisitos Previos

* **Java JDK 17** o superior.
* **Maven 3.8+** (o usar el wrapper incluido `./mvnw` / `mvnw.cmd`).
* **MongoDB** (local en `mongodb://localhost:27017` o instancia en MongoDB Atlas).
* *(Opcional)* Claves de API para servicios externos: Groq, Stripe, Twilio, Gmail SMTP y OAuth2 (Google/GitHub).

---

## Instalación y Ejecución

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/cardenaswalker2/ClinicaApp.git
   cd ClinicaApp/clinicaapp
   ```

2. **Configurar las variables de entorno / propiedades:**
   Copia el archivo de ejemplo y ajusta tus credenciales sin subirlas al repositorio:
   ```bash
   cp src/main/resources/application.properties.example src/main/resources/application.properties
   ```
   Variables de entorno principales:
   * `MONGODB_URI` (por defecto `mongodb://localhost:27017/clinica_veterinaria_db`)
   * `PORT` (por defecto `8080`)
   * `GROQ_API_KEY`, `GROQ_API_MODEL`
   * `STRIPE_PUBLIC_KEY`, `STRIPE_SECRET_KEY`
   * `MAIL_USERNAME`, `MAIL_PASSWORD`
   * `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER`
   * `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`

3. **Compilar y ejecutar la aplicación:**
   * En Windows:
     ```powershell
     .\mvnw.cmd spring-boot:run
     ```
   * En Linux / macOS:
     ```bash
     ./mvnw spring-boot:run
     ```

4. **Acceder a la aplicación:**
   Abre tu navegador en `http://localhost:8080`.

