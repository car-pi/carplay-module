# syntax=docker/dockerfile:1.7

ARG NODE_VERSION=20-bookworm
ARG TARGETPLATFORM
ARG TARGETARCH

FROM node:${NODE_VERSION} AS node-base
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libgtk-3-0 libnss3 libasound2 libxss1 libxtst6 libdrm2 libgbm1 \
    libxkbcommon0 libxshmfence1 libxcb-dri3-0 ca-certificates \
    build-essential python3 make g++ \
    libusb-1.0-0 libusb-1.0-0-dev udev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src/react-carplay
USER node

# ---- Dev image ----
FROM node-base AS dev
ENV NODE_ENV=development

WORKDIR /src/react-carplay

# Copy source code
COPY src/react-carplay/. .

USER root
RUN mkdir -p node_modules && chown -R node:node .

USER node

RUN --mount=type=cache,target=/home/node/.npm \
    bash -lc 'if [ -f package-lock.json ]; then npm ci || true; fi'