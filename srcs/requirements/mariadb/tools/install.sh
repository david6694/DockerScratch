#!/bin/sh
set -e

# Configuration du dépôt d'archives principal (sans security)
echo "deb http://archive.debian.org/debian/ bullseye main" > /etc/apt/sources.list
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

rm -rf /var/lib/apt/lists/*
apt-get update -y --allow-insecure-repositories

# Autoriser le downgrade de perl-base pour résoudre le conflit de dépendance
apt-get install -y --allow-unauthenticated --allow-downgrades \
    perl-base=5.32.1-4+deb11u3

# Installation des paquets MariaDB
apt-get install -y --allow-unauthenticated \
    mariadb-server \
    mariadb-client \
    curl \
    wget
