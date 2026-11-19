## 1. Prerequisites & Environment Setup

- **Virtual Machine & Operating System**: A Linux virtual machine (Debian or Ubuntu) is required to isolate the stack.
- **Required Software Tools**: `docker`, `docker-compose` (v2), `make`, `curl`, `openssl`, and `git`.
- **Configuration Files & Secrets**:
  Before starting the project, copy the `.example` templates into the actual configuration files:
  ```bash
  cp srcs/.env.example srcs/.env
  cp secrets/credentials.txt.example secrets/credentials.txt
  cp secrets/db_password.txt.example secrets/db_password.txt
  cp secrets/db_root_password.txt.example secrets/db_root_password.txt
  ```
  Then set your actual credentials in these files (which are automatically ignored by Git via `.gitignore`).
- **Local DNS Configuration**: Add the following entry to the host VM's `/etc/hosts` file to redirect the required domain name:
  ```text
  127.0.0.1 dgarrido.42.fr
  ```

## 2. Building and Running (Makefile & Docker Compose)

The entire lifecycle of the infrastructure is managed by the `Makefile` at the root of the project:

- **`make` / `make up`**: Automatically creates the data directories on the host (`/home/dgarrido/data/`) and builds/starts the containers in detached mode.
- **`make stop`**: Pauses the running containers without removing the containers or networks.
- **`make down`**: Stops and removes the containers as well as the internal bridge network.
- **`make clean`**: Runs `down` and removes the generated Docker images (`docker compose down --rmi all`).
- **`make fclean`**: Full cleanup: runs `clean` and permanently deletes the data directories located in `/home/dgarrido/data/`.
- **`make re`**: Full rebuild from scratch (`fclean` followed by `all`).

## 3. Service Management & Inspection Commands

- **View container logs**:
  ```bash
  docker logs nginx
  docker logs wordpress
  docker logs mariadb
  ```

- **Check running containers and exposed ports**:
  ```bash
  docker ps
  ```
  *(Only the NGINX container should expose port 443 to the host).*

- **Inspect Docker named volumes**:
  ```bash
  docker volume ls
  docker volume inspect db_data
  docker volume inspect wp_data
  ```

- **Test TLS protocol compliance**:
  ```bash
  openssl s_client -connect dgarrido.42.fr:443 -tls1_3 # Must succeed
  openssl s_client -connect dgarrido.42.fr:443 -tls1_2 # Must succeed
  openssl s_client -connect dgarrido.42.fr:443 -tls1_1 # Must be rejected
  ```

- **Test resilience and automatic restart (`restart: always`)**:
  ```bash
  docker exec mariadb kill -9 1
  sleep 3
  docker ps
  ```

## 4. Storage Architecture & Data Persistence

Data persistence relies on two **Docker named volumes** configured with the bind driver (`type: none`, `o: bind`, `device: /home/dgarrido/data/...`):

- **Database Volume (`db_data`)**: Maps the host directory `/home/dgarrido/data/db_data` to `/var/lib/mysql` inside the MariaDB container.
- **Web Files Volume (`wp_data`)**: Maps the host directory `/home/dgarrido/data/wp_data` to `/var/www/wordpress` inside the WordPress container.

All website modifications and databases persist across `make down` or a virtual machine reboot. Only the `make fclean` rule deletes the data directories on the host partition.
