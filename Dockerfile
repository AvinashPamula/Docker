# --- STAGE 1: Build & Dependencies ---
FROM node:20-alpine AS installer

# Create app directory
WORKDIR /app

# Copy package.json AND package-lock.json (if available)
# Using the wildcard * ensures it doesn't fail if lockfile is missing
COPY package*.json ./

# Install dependencies (This will now find the file)
RUN npm install

# Copy your app.js
COPY app.js ./

# --- STAGE 2: Production Runtime ---
FROM node:20-alpine AS runtime

# Set to production for better performance with Express
ENV NODE_ENV=production

WORKDIR /app

# Copy ONLY what is needed from the installer stage
COPY --from=installer /app/node_modules ./node_modules
COPY --from=installer /app/package*.json ./
COPY --from=installer /app/app.js ./

# Security: Don't run as root
USER node

# Match the port in your app.js
EXPOSE 9000

CMD ["node", "app.js"]
