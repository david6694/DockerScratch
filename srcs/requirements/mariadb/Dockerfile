FROM debian:bullseye-slim

# Avoid interactive prompts from apt during image build
ENV DEBIAN_FRONTEND=noninteractive

# Copy and run the package installation script
COPY tools/install.sh /tmp/install.sh
RUN sh /tmp/install.sh

# Expose standard MariaDB port for internal network communication
EXPOSE 3306

# Copy database initialization script and set ENTRYPOINT
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

ENTRYPOINT [ "/usr/local/bin/init.sh" ]
