FROM debian:bullseye-slim

# Avoid interactive prompts from apt during image build
ENV DEBIAN_FRONTEND=noninteractive

# Copy and run installation script
COPY tools/install.sh /tmp/install.sh
RUN sh /tmp/install.sh

# Generate a self-signed SSL/TLS certificate using OpenSSL
# CN must match your 42 domain name (devgarri.42.fr)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=devgarri.42.fr"

# Expose only the standard HTTPS port to the outside world
EXPOSE 443

# Copy custom Nginx virtual host configuration file
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Run Nginx in the foreground as PID 1 to keep the container active
CMD [ "nginx", "-g", "daemon off;" ]
