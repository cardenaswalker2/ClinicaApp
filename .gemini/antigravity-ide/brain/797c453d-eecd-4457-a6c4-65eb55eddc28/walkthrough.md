# Resumen de Cambios y Despliegue en Render

Hemos configurado todo lo necesario para subir el proyecto a GitHub y prepararlo para desplegarlo en Render usando Docker y MongoDB Atlas.

## Cambios Realizados

1. **Ignorados de Git (`.gitignore`)**: Se creó el archivo [.gitignore](file:///c:/Users/USUARIO/Downloads/clinicaapp/.gitignore) en la raíz para evitar subir archivos de compilación, configuraciones de IDE y binarios innecesarios.
2. **Dockerfile**: Se agregó el archivo [Dockerfile](file:///c:/Users/USUARIO/Downloads/clinicaapp/clinicaapp/Dockerfile) de construcción multi-etapa usando Maven y Java 17 en la subcarpeta `clinicaapp`. Copia automáticamente los archivos `.model` necesarios para las inferencias.
3. **Repositorio Git**: Se inicializó el repositorio local en la raíz del proyecto, se vinculó a `https://github.com/cardenaswalker2/ClinicaApp.git`, y se inició la subida (push) a la rama `main`.

---

## Guía Paso a Paso para el Despliegue en Render

Para desplegar esta aplicación en Render, sigue estos pasos:

### 1. Crear un nuevo servicio web en Render
1. Ve a tu panel de **Render** y haz clic en **New +** > **Web Service**.
2. Conecta tu cuenta de GitHub y selecciona el repositorio **ClinicaApp**.

### 2. Configurar los parámetros básicos
* **Name**: `clinicaapp` (o el nombre que prefieras).
* **Region**: Selecciona la más cercana a ti.
* **Branch**: `main`.
* **Root Directory**: `clinicaapp` (Esto es muy importante, ya que el proyecto de Spring Boot y el Dockerfile están dentro de esta subcarpeta).
* **Runtime**: `Docker`.

### 3. Configurar las variables de entorno
Haz clic en **Advanced** y añade las siguientes variables en la sección **Environment Variables**:
* `MONGODB_URI`: Coloca tu cadena de conexión de MongoDB Atlas. Ejemplo: `mongodb+srv://<usuario>:<password>@cluster0.xxxx.mongodb.net/clinica_veterinaria_db?retryWrites=true&w=majority`
* `PORT`: `8080` (Opcional, Render mapea el puerto automáticamente, pero ayuda a asegurar que exponga el puerto correcto).
* Agrega cualquier otra variable necesaria si utilizas APIs externas (`STRIPE_PUBLIC_KEY`, `STRIPE_SECRET_KEY`, `GROQ_API_KEY`, etc.).

### 4. Desplegar
Haz clic en **Create Web Service**. Render detectará el Dockerfile en la subcarpeta `clinicaapp`, compilará la imagen de Docker, la ejecutará y conectará la aplicación a tu base de datos de MongoDB Atlas de forma segura.
