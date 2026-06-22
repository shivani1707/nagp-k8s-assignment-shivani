# ── Stage 1: Build ──────────────────────────────────────────────────────────
# Use official Maven image with Java 17 to compile the project
FROM maven:3.9.5-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first so Maven can cache dependencies (faster rebuilds)
COPY pom.xml .
RUN mvn dependency:go-offline -q

# Copy source code and build the JAR
COPY src ./src
RUN mvn clean package -DskipTests -q

# ── Stage 2: Extract layers ──────────────────────────────────────────────────
# Spring Boot layered JAR allows Docker to cache dependencies separately
FROM eclipse-temurin:17-jre AS extractor
WORKDIR /app
COPY --from=builder /app/target/product-api.jar product-api.jar
RUN java -Djarmode=layertools -jar product-api.jar extract

# ── Stage 3: Final minimal image ─────────────────────────────────────────────
FROM eclipse-temurin:17-jre

WORKDIR /app

# Create non-root user for security best practice
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Copy each layer separately — Docker caches unchanged layers
COPY --from=extractor /app/dependencies/ ./
COPY --from=extractor /app/spring-boot-loader/ ./
COPY --from=extractor /app/snapshot-dependencies/ ./
COPY --from=extractor /app/application/ ./

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Health check so Docker knows when the container is ready
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/api/health || exit 1

# Start the application
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
