#!/bin/sh
set -e

# 1. Supprimer le dépôt security expiré qui bloque les mises à jour APT sur Bullseye
sed -i '/security/d' /etc/apt/sources.list

# 2. Désactiver le contrôle de date de validité d'APT
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until
echo 'Acquire::Check-Date "false";' >> /etc/apt/apt.conf.d/99no-check-valid-until

# 2. S'assurer que le dépôt security est bien présent
if ! grep -q "security" /etc/apt/sources.list; then
        echo "deb http://deb.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.l
fi

# 3. Nettoyer les listes d'index APT
rm -rf /var/lib/apt/lists/*

# 4. Mettre à jour l'index des paquets depuis le dépôt principal
apt-get update -y --allow-releaseinfo-change

# 5. Installer NGINX et OpenSSL
apt-get install -y --fix-missing nginx openssl

# 6. Configurer le lien symbolique du site par défaut
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
