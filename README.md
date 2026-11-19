# DockerScratch

A containerized, isolated web infrastructure built from scratch using **Docker** and **Docker Compose**.

## Architecture

The stack consists of three custom-built services connected through a dedicated internal Docker bridge network:

- **NGINX**: Reverse proxy and single entry point over HTTPS (port `443`) using TLS 1.2 / 1.3 with a self-signed certificate.
- **WordPress + PHP-FPM**: Runs in its own container and communicates with NGINX over FastCGI (internal port `9000`).
- **MariaDB**: Relational database storing WordPress data, isolated on the internal network (port `3306`).

Persistent data is stored using Docker named volumes bound to the host filesystem, and sensitive credentials are injected via **Docker Secrets**.

## Project Structure

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore
├── secrets/
│   ├── credentials.txt.example
│   ├── db_password.txt.example
│   └── db_root_password.txt.example
└── srcs/
    ├── .env.example
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

## Quick Start

1. **Copy the configuration and secret templates**:
   ```bash
   cp srcs/.env.example srcs/.env
   cp secrets/credentials.txt.example secrets/credentials.txt
   cp secrets/db_password.txt.example secrets/db_password.txt
   cp secrets/db_root_password.txt.example secrets/db_root_password.txt
   ```
   Edit these files with your own values (they are ignored by Git).

2. **Add the local domain to `/etc/hosts`**:
   ```text
   127.0.0.1 dgarrido.42.fr
   ```

3. **Build and launch the stack**:
   ```bash
   make
   ```

4. **Access the site**:
   - Website: `https://dgarrido.42.fr`
   - Admin panel: `https://dgarrido.42.fr/wp-admin`

## Common Commands

| Command | Description |
| --- | --- |
| `make` / `make up` | Create host data directories, build images, and start containers |
| `make stop` | Stop running containers without removing them |
| `make start` | Restart stopped containers |
| `make down` | Stop and remove containers and the internal network |
| `make clean` | Run `down`, remove custom images, and prune Docker resources |
| `make fclean` | Full cleanup including volumes and host data directories |
| `make re` | Full cleanup followed by a complete rebuild |

## Documentation

- [USER_DOC.md](USER_DOC.md) — End-user guide (services, startup/shutdown, credentials, health checks).
- [DEV_DOC.md](DEV_DOC.md) — Developer guide (prerequisites, build lifecycle, inspection commands, storage architecture).
