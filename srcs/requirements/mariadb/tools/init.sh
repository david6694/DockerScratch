#!/bin/sh
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Configuration réseau
sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
if ! grep -q "skip-name-resolve" /etc/mysql/mariadb.conf.d/50-server.cnf; then
    echo "skip-name-resolve" >> /etc/mysql/mariadb.conf.d/50-server.cnf
fi

MYSQL_PASSWORD=$(cat /run/secrets/db_password | tr -d '\r\n')
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password | tr -d '\r\n')

# 3. Initialisation si premier démarrage (OBLIGATOIRE)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Première initialisation de MariaDB..."

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    echo "Démarrage temporaire de MariaDB pour configuration..."
    mysqld --user=mysql --skip-networking &
    pid="$!"

    until mysqladmin ping --socket=/run/mysqld/mysqld.sock >/dev/null 2>&1; do
        sleep 1
    done

    echo "Création de la base de données et des utilisateurs..."
    mysql --socket=/run/mysqld/mysqld.sock <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        FLUSH PRIVILEGES;
EOSQL

    echo "Arrêt du serveur temporaire..."
    mysqladmin --socket=/run/mysqld/mysqld.sock -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
    echo "Initialisation terminée avec succès."
fi

# Lancement final de MariaDB au premier plan
exec mysqld --user=mysql --bind-address=0.0.0.0 --skip-name-resolve
