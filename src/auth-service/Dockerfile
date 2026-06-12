# Stage 1 — Builder
FROM node:22-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies
RUN npm ci --only=production

# Copy source code
COPY src/ ./src/

# Stage 2 — Runtime (Hardened)
FROM node:22-alpine AS runtime

# Security: create non-root user
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy only production artifacts from builder
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/src ./src
COPY --chown=appuser:appgroup package*.json ./

# Security: switch to non-root user
USER appuser

# Security: expose only required port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3001/health || exit 1

# Start application
CMD ["node", "src/app.js"]
