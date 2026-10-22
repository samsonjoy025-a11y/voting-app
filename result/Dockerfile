
FROM node:18-slim

# Install only the OS tools needed by the application.
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

# Keep nodemon available for the existing local development workflow.
RUN npm install -g nodemon

# Install locked application dependencies.
COPY package*.json ./

RUN npm ci && \
    npm cache clean --force && \
    mv /usr/local/app/node_modules /node_modules

# Create an unprivileged account for running the application.
RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --home-dir /home/appuser \
    --create-home appuser

# Copy the application files with appropriate ownership.
COPY --chown=appuser:appgroup . .

ENV PORT=80

EXPOSE 80

# Check whether the result HTTP endpoint responds successfully.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl --fail --silent http://127.0.0.1:80/ || exit 1

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]

USER appuser
