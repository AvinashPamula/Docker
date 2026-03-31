# --- Stage 1: Build Stage ---
FROM maven:3.8.5-openjdk-17-slim AS build

WORKDIR /app

# Copy only the pom.xml first to cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests

# --- Stage 2: Runtime Stage ---
FROM openjdk:17-jdk-slim

WORKDIR /app

# SRE Best Practice: Run as a non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Copy the compiled .jar file from the build stage
# Note: Ensure the 'target' filename matches your project's artifact ID
COPY --from=build /app/target/*.jar app.jar

# Change ownership to the non-root user
RUN chown appuser:appgroup app.jar
USER appuser

# Expose the port (must match your service's targetPort: 3000)
EXPOSE 3000

# Optimization: Use exec form for CMD to allow SIGTERM propagation
ENTRYPOINT ["java", "-Xmx512m", "-Xms128m", "-jar", "app.jar"]
