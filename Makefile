# Project variables
NAME = inception
SRCS_DIR = srcs
COMPOSE_FILE = $(SRCS_DIR)/docker-compose.yml
DATA_PATH = /home/devgarri/data

# Default rule: build and bring up the infrastructure
all: up

# Create persistent volume directories on host if missing, then build and start containers
up:
	@mkdir -p $(DATA_PATH)/db_data
	@mkdir -p $(DATA_PATH)/wp_data
	@docker compose -f $(COMPOSE_FILE) up -d --build

# Stop running containers without destroying them or losing data
stop:
	@docker compose -f $(COMPOSE_FILE) stop

# Start previously stopped containers
start:
	@docker compose -f $(COMPOSE_FILE) start

# Stop and remove containers and internal networks
down:
	@docker compose -f $(COMPOSE_FILE) down

# Clean containers, networks, and custom built Docker images
clean: down
	@docker image rm -f inception-mariadb inception-wordpress inception-nginx 2>/dev/null || true
	@docker system prune -a -f

# Full clean: remove containers, images, networks, volumes, and persistent host data
fclean: clean
	@docker volume rm -f $$(docker volume ls -q) 2>/dev/null || true
	@sudo rm -rf $(DATA_PATH)/db_data
	@sudo rm -rf $(DATA_PATH)/wp_data

# Rebuild the entire infrastructure from scratch
re: fclean all

.PHONY: all up stop start down clean fclean re
