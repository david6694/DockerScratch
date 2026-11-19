FROM debian:bullseye-slim

# Avoid interactive prompts from apt during image build
ENV DEBIAN_FRONTEND=noninteractive

# Copy and run installation script
COPY tools/install.sh /tmp/install.sh
RUN sh /tmp/install.sh

# Expose PHP-FPM standard FastCGI port
EXPOSE 9000

# Copy PHP-FPM pool configuration file
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copy startup script
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

ENTRYPOINT [ "/usr/local/bin/init.sh" ]
