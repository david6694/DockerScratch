# USER_DOC.md — User Documentation (DockerScratch)

## 1. Services Provided by the Infrastructure
The DockerScratch infrastructure deploys a complete, secure, and isolated web stack composed of three main services:
- **NGINX (Web Server & Reverse Proxy)**: Single entry point to the infrastructure via port 443 (HTTPS), secured with TLS 1.2/1.3.
- **WordPress + PHP-FPM**: Web application / CMS running autonomously in its own container, communicating with NGINX over the FastCGI protocol (internal port 9000).
- **MariaDB (SQL Database)**: Relational database server managing WordPress tables and content, accessible only on the internal Docker network (port 3306).

---

## 2. Starting and Stopping the Project
All project management commands must be executed from the root of the repository using the `Makefile`:

- **Start the project**:
  ```bash
  make
  # or
  make up
  ```
  *This command automatically creates the required data directories on the host machine (`/home/<login>/data/`), then builds and starts all containers.*

- **Pause / Temporarily stop**:
  ```bash
  make stop
  ```
  *Stops the running containers without removing them. You can quickly restart them with `make up`.*

- **Stop and remove containers**:
  ```bash
  make down
  ```
  *Stops and removes the containers along with the virtual network. Persistent data stored in the volumes remains intact.*

---

## 3. Accessing the Website and Admin Panel
1. **Local domain redirection**:
   Make sure the following line is present in your machine's `/etc/hosts` file:
   ```text
   127.0.0.1 <login>.42.fr
   ```
2. **Access the WordPress website**:
   Open your web browser and navigate to:
   ```text
   https://<login>.42.fr
   ```
   *(Accept the security warning related to the self-signed TLS certificate).*
3. **Access the WordPress administration panel (WP-Admin)**:
   Access the admin interface via the URL:
   ```text
   https://<login>.42.fr/wp-admin
   ```

---

## 4. Credentials Location and Management (Secrets)
All confidential information and passwords are stored in the `secrets/` directory at the root of the repository:
- **`secrets/credentials.txt`**: Contains the WordPress administrator and regular user credentials (`WP_ADMIN_USER`, `WP_ADMIN_PASSWORD`, `WP_USER`, `WP_USER_PASSWORD`).
  *Reminder: Per the subject requirements, the administrator username does not contain `admin` or `Admin`.*
- **`secrets/db_password.txt`**: Password for the MariaDB application user.
- **`secrets/db_root_password.txt`**: Password for the MariaDB `root` account.

*Security note: These secret files are strictly ignored by Git via `.gitignore` so that passwords are never published to the remote repository.*

---

## 5. Verifying That Services Are Running Properly
To verify that all services are working properly:

1. **Check the status of running containers**:
   ```bash
   docker ps
   ```
   *All three containers (`nginx`, `wordpress`, `mariadb`) should show the `Up` status. Only NGINX should have port `443` exposed to the host machine.*

2. **Check the logs of a service**:
   ```bash
   docker logs nginx
   docker logs wordpress
   docker logs mariadb
   ```

3. **Test HTTPS access from the terminal**:
   ```bash
   curl -k https://<login>.42.fr
   ```
