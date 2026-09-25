# syntax=docker/dockerfile:1.7

# ------------------------------------------------------------------------------
# Hardened Next.js production image
# ------------------------------------------------------------------------------
# Notes:
# - Use the same supported Node LTS patch and Alpine ABI for all stages.
# - The exact Node and Alpine versions make rebuilds reproducible by tag.

FROM node:24.21.0-alpine3.22 AS deps
WORKDIR /app

# Install dependencies deterministically from lockfile.
COPY package*.json ./
RUN npm ci

FROM node:24.21.0-alpine3.22 AS builder
WORKDIR /app

# Reuse deterministic node_modules from deps stage.
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Build standalone output.
RUN npm run build

FROM node:24.21.0-alpine3.22 AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3001
ENV HOSTNAME=0.0.0.0
ENV NEXT_TELEMETRY_DISABLED=1
RUN addgroup -g 10001 -S nextjs && adduser -u 10001 -S -G nextjs nextjs

# Copy only runtime artifacts with non-root ownership.
COPY --from=builder --chown=10001:10001 /app/public ./public
COPY --from=builder --chown=10001:10001 /app/.next/standalone ./
COPY --from=builder --chown=10001:10001 /app/.next/static ./.next/static

USER 10001:10001

EXPOSE 3001

# OCI labels (optional but useful for inventory/traceability).
LABEL org.opencontainers.image.title="tared-ltd"
LABEL org.opencontainers.image.description="Next.js production image"

# Distroless node entrypoint executes server.js directly.
CMD ["node", "server.js"]
