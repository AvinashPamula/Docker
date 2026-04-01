# --- STAGE 1: Build & Dependencies ---
FROM node:20-alpine AS installer

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the application source code
COPY app.js ./


# --- STAGE 2: Production Runtime ---
FROM node:20-alpine AS runtime

# Set environment to production for performance optimizations
ENV NODE_ENV=production

WORKDIR /app

# Only copy the node_modules and app.js from the 'installer' stage
COPY --from=installer /app/node_modules ./node_modules
COPY --from=installer /app/package*.json ./
COPY --from=installer /app/app.js ./

# Run as a non-root user for better security
USER node

EXPOSE 9000

CMD ["node", "app.js"]
