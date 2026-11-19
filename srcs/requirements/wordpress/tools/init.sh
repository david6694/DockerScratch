#!/bin/sh
set -e

# Read WordPress admin credentials from Docker secret
WP_ADMIN_USER=$(grep "WP_ADMIN_USER=" /run/secrets/credentials | cut -d'=' -f2)
WP_ADMIN_PASSWORD=$(grep "WP_ADMIN_PASSWORD=" /run/secrets/credentials | cut -d'=' -f2)

# Read second WordPress user credentials from Docker secret
WP_USER=$(grep "WP_USER=" /run/secrets/credentials | cut -d'=' -f2)
WP_USER_PASSWORD=$(grep "WP_USER_PASSWORD=" /run/secrets/credentials | cut -d'=' -f2)

# Read MariaDB user password from Docker secret
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Ensure the shared volume directory exists with correct web server ownership
mkdir -p /var/www/wordpress
chown -R www-data:www-data /var/www/wordpress

# Copy WordPress core files if the volume is empty (first-time boot persistence check)
if [ ! -f "/var/www/wordpress/wp-settings.php" ]; then
    echo "Copying WordPress core files to shared volume..."
    cp -r /usr/src/wordpress/* /var/www/wordpress/
fi

cd /var/www/wordpress

# Active polling to wait until the MariaDB container is fully ready to accept connections
echo "Waiting for MariaDB database connection..."
until mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    sleep 1
done
echo "Database is ready!"

# Configure and install WordPress if configuration doesn't exist
if [ ! -f "wp-config.php" ]; then
    echo "Configuring and installing WordPress..."

    # Generate wp-config.php with database connection details
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root

    # Install WordPress site core database tables and primary admin
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="Inception Website" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_USER}@student.42.fr" \
        --skip-email \
        --allow-root

    # Create the mandatory second non-administrator user
    wp user create \
        "${WP_USER}" \
        "${WP_USER}@student.42.fr" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    echo "WordPress configured and installed successfully!"
fi

# Double check files ownership for security and web server compatibility
chown -R www-data:www-data /var/www/wordpress

# Run PHP-FPM in the foreground (PID 1)
echo "Starting PHP-FPM..."
exec php-fpm7.4 -F
