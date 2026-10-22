# base defines a base stage that uses the official python runtime base image
FROM python:3.11-slim AS base

# Add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Set the application directory
WORKDIR /usr/local/app

# Install our requirements.txt
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# dev defines a stage for development, where it'll watch for filesystem changes
FROM base AS dev
RUN pip install watchdog && \
    groupadd --system appgroup && \
    useradd --system --gid appgroup --home-dir /home/appuser --create-home appuser
USER appuser
ENV FLASK_ENV=development
CMD ["python", "app.py"]
# final defines the stage that will bundle the application for production
FROM base AS final

# Create a dedicated non-root user and group
RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --home-dir /home/appuser \
    --create-home appuser

# Copy application files and assign ownership to the non-root user
COPY --chown=appuser:appgroup . .


# Run the application without root privileges
USER appuser

# Make port 80 available for links and/or publish
EXPOSE 80

# Check whether the voting application responds over HTTP
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl --fail --silent http://127.0.0.1/ || exit 1

# Define our command to be run when launching the container
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
