# Etapa 1: Compilación
FROM maven:3.8.8-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Ejecución
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
# Copiar modelos Weka
COPY no_show_citas.model .
COPY riesgo_articular.model .
COPY health_advanced.model .
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
