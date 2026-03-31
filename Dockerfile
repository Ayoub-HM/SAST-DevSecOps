# Use a specific nginx base image, not latest.
FROM nginx:1.29.7-alpine

# Metadata
LABEL maintainer="TP DevOps"
LABEL description="Application DevOps securisee"
LABEL org.opencontainers.image.source="https://github.com/Ayoub-HM/TP2_Pipeline-DevSecOps-avec-GitHub-Actions"

# Create a dedicated non-root user.
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

# Install only what is needed and apply package updates.
RUN apk add --no-cache ca-certificates wget && \
    apk upgrade --no-cache

# Copy nginx configuration and static app files with ownership.
COPY --chown=appuser:appgroup nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=appuser:appgroup src/ /usr/share/nginx/html/

# Ensure runtime paths are writable by the non-root user.
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/cache/nginx

# Run as non-root.
USER appuser

# Expose the port.
EXPOSE 8080

# Health check.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

# Start command.
CMD ["nginx", "-g", "daemon off;"]
