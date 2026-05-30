# syntax=docker/dockerfile:1.7

# ------------------------------------------------------------------------------
# Hardened Next.js production image
# ------------------------------------------------------------------------------
# Notes:
# - Keep builder/runtime on Node 22 for ABI consistency.
# - Image digests pinned on 2026-05-30.

FROM node:22.16.0-alpine3.22@sha256:41e4389f3d988d2ed55392df4db1420ad048ae53324a8e2b7c6d19508288107e AS deps
WORKDIR /app

# Install dependencies deterministically from lockfile.
COPY package*.json ./
RUN npm ci

FROM node:22.16.0-alpine3.22@sha256:41e4389f3d988d2ed55392df4db1420ad048ae53324a8e2b7c6d19508288107e AS builder
WORKDIR /app

# Reuse deterministic node_modules from deps stage.
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Build standalone output.
RUN npm run build

FROM gcr.io/distroless/nodejs22-debian12:nonroot@sha256:13593b7570658e8477de39e2f4a1dd25db2f836d68a0ba771251572d23bb4f8e AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3001
ENV HOSTNAME=0.0.0.0
ENV NEXT_TELEMETRY_DISABLED=1

# Copy only runtime artifacts with non-root ownership.
COPY --from=builder --chown=nonroot:nonroot /app/public ./public
COPY --from=builder --chown=nonroot:nonroot /app/.next/standalone ./
COPY --from=builder --chown=nonroot:nonroot /app/.next/static ./.next/static

EXPOSE 3001

# OCI labels (optional but useful for inventory/traceability).
LABEL org.opencontainers.image.title="tared-ltd"
LABEL org.opencontainers.image.description="Next.js production image"

# Distroless node entrypoint executes server.js directly.
CMD ["server.js"]
