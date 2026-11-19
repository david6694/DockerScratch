#!/bin/sh
set -e

# Configuration du dépôt d'archives principal (sans security)
echo "deb http://archive.debian.org/debian/ bullseye main" > /etc/apt/sources.list
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

rm -rf /var/lib/apt/lists/*
apt-get update -y --allow-insecure-repositories

# Résolution préventive du conflit perl-base si nécessaire
apt-get install -y --allow-unauthenticated --allow-downgrades \
    perl-base=5.32.1-4+deb11u3 || true

# Installation de PHP 7.4 et des outils
apt-get install -y --allow-unauthenticated \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-soap \
    php7.4-xml \
    php7.4-xmlrpc \
    php7.4-zip \
    mariadb-client \
    curl \
    wget

mkdir -p /run/php

# Installation de WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Téléchargement des sources WordPress
mkdir -p /usr/src/wordpress
cd /usr/src/wordpress
wp core download --allow-root
