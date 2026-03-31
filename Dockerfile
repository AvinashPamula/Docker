# --- STAGE 1: Build Stage ---
# Use the Gradle image to compile the application
FROM gradle:8.5-jdk17-alpine AS builder

WORKDIR /app

# 1. Copy only the Gradle wrapper and configuration files first
# This allows Docker to cache your dependencies (major time saver!)
COPY build.gradle settings.gradle ./
# If you have a 'gradle' folder with the wrapper, copy it too:
# COPY gradle ./gradle
# COPY gradlew ./

# Download dependencies (this will fail if no source, so we use a trick or just skip to build)
# RUN gradle build -x test --continue 

# 2. Copy the source code and build the application
COPY src ./src
RUN gradle clean bootJar -x test

# --- STAGE 2: Runtime Stage ---
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# 3. Security: Run as a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 4. Copy the compiled JAR from the builder stage
# Gradle usually puts the JAR in build/libs/
COPY --from=builder /app/build/libs/*.jar app.jar

# 5. Set ownership and switch user
RUN chown appuser:appgroup app.jar
USER appuser

# 6. Expose the port (matches your GKE Service targetPort: 3000)
EXPOSE 3000

# 7. JVM Tuning for your 512Mi GKE Limit
ENTRYPOINT ["java", "-Xms128m", "-Xmx400m", "-jar", "app.jar"]
