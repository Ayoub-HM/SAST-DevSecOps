# Use a patched base image to reduce OS-level CVEs reported by Trivy.
FROM nginx:1.29.5-alpine-slim

# Metadata
LABEL maintainer="TP DevOps"
LABEL description="Application DevOps securisee"
LABEL org.opencontainers.image.source="https://github.com/Ayoub-HM/TP2_Pipeline-DevSecOps-avec-GitHub-Actions"

# Copy nginx config
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copy static app files
COPY src/ /usr/share/nginx/html/

# Upgrade OS packages from the base image to pull security fixes.
RUN apk --no-cache upgrade

# Set permissions for built-in nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Ensure nginx can write runtime/cache files
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid && \
    chown -R nginx:nginx /var/cache/nginx

# Run as non-root
USER nginx

# Expose the port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

# Start command
CMD ["nginx", "-g", "daemon off;"]
