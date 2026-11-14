# ==============================================================================
# Production Dockerfile for EduManagement Spring Boot Backend
# Multi-stage build with Eclipse Temurin OpenJDK 21
# ==============================================================================

# --- Stage 1: Build Application Artifact ---
FROM maven:3.9.9-eclipse-temurin-21-alpine AS builder

WORKDIR /build

# Cache Maven dependencies layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy application source code
COPY src ./src

# Package production executable JAR without running test suites during container build
RUN mvn clean package -DskipTests -B

# --- Stage 2: Minimal Production Runtime ---
FROM eclipse-temurin:21-jre-alpine

LABEL maintainer="EduManagement Team"
LABEL description="Production Spring Boot Backend for EduManagement System"

# Install curl for Docker health check and configure Vietnam timezone
RUN apk add --no-cache curl tzdata && \
    cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    echo "Asia/Ho_Chi_Minh" > /etc/timezone

# Security: Run application as non-root dedicated user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy artifact from build stage and assign ownership
COPY --from=builder --chown=appuser:appgroup /build/target/*.jar app.jar

USER appuser

# JVM Container Tuning
ENV SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/api/v1/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
