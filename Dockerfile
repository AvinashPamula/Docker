# --- STAGE 1: Build Stage (The "Heavy" lifting) ---
# We use a full JDK and Maven to compile the code.
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# 1. Copy only the pom.xml to cache dependencies. 
# This speeds up future builds if dependencies haven't changed.
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 2. Copy source code and build the fat JAR.
COPY src ./src
RUN mvn clean package -DskipTests

# --- STAGE 2: Runtime Stage (The "Slim" footprint) ---
# We switch to a lightweight JRE (Java Runtime Environment) for production.
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# 3. SRE Best Practice: Create a non-root user for security.
# GKE pods should never run as root to minimize the blast radius of a breach.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 4. Copy the compiled JAR from the builder stage.
# Ensure the name matches your project's artifactId in pom.xml.
COPY --from=builder /app/target/*.jar app.jar

# 5. Set ownership to the non-root user.
RUN chown appuser:appgroup app.jar
USER appuser

# 6. Expose the port (Must match your service's targetPort: 3000).
EXPOSE 3000

# 7. Optimization: JVM Memory Tuning.
# Since your values.yaml has a 512Mi limit, we set Xmx to 400m 
# to leave room for the OS and non-heap memory.
ENTRYPOINT ["java", "-Xms128m", "-Xmx400m", "-jar", "app.jar"]
