
# Use the Node.js base image for the application
FROM node:22-bookworm-slim AS base

# Install Tini for reliable signal handling
RUN apt-get update && \
    apt-get install -y --no-install-recommends tini && \
    rm -rf /var/lib/apt/lists/*

# Set the application directory
WORKDIR /usr/local/app

# Copy dependency manifests first for better build caching
COPY package.json package-lock.json ./

# Install production dependencies only
RUN npm ci --omit=dev && \
    npm cache clean --force && \
    mv /usr/local/app/node_modules /node_modules

# Production stage
FROM node:22-bookworm-slim AS final

# Install Tini in the final image
RUN apt-get update && \
    apt-get install -y --no-install-recommends tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

# Copy installed dependencies and application files
COPY --from=base /node_modules /node_modules
COPY --chown=node:node . .

# Run as the existing unprivileged Node user
USER node

ENV NODE_ENV=production
ENV PORT=80

EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
