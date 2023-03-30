#!/bin/bash

# Script to install Nginx, MariaDB, and WordPress on Ubuntu/some Linux Distros
# An original script by rootlodge.com

# Prompt user for domain name
read -p "Enter your domain name (without www): " DOMAIN_NAME

# Prompt user for database details
read -p "Enter your desired database name: " DATABASE_NAME
read -p "Enter your desired database username: " DATABASE_USER
read -s -p "Enter your desired database password: " DATABASE_PASSWORD

# Update system packages
apt-get update
apt-get upgrade -y

# Install Nginx
apt-get install nginx -y

# Install MariaDB
apt-get install mariadb-server -y
mysql_secure_installation

# Install PHP and required extensions
apt-get install php8.2-fpm php8.2-common php8.2-mysql php8.2-gd php8.2-cli php8.2-curl php8.2-xmlrpc php8.2-mbstring php8.2-xml php8.2-bcmath php8.2-json -y

# Create new WordPress database
mysql -uroot <<EOF
CREATE DATABASE $DATABASE_NAME;
CREATE USER '$DATABASE_USER'@'localhost' IDENTIFIED BY '$DATABASE_PASSWORD';
GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$DATABASE_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# Download and extract WordPress
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz

# Copy WordPress files to Nginx web root
cp -R /tmp/wordpress/* /var/www/html/
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Configure WordPress
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/$DATABASE_NAME/g" /var/www/html/wp-config.php
sed -i "s/username_here/$DATABASE_USER/g" /var/www/html/wp-config.php
sed -i "s/password_here/$DATABASE_PASSWORD/g" /var/www/html/wp-config.php

# Start Nginx and PHP-FPM services
systemctl start nginx
systemctl start php8.2-fpm

# Enable Nginx and PHP-FPM services to start automatically on system boot
systemctl enable nginx
systemctl enable php8.2-fpm

# Display final message to the user
echo "Installation complete! You can access your website at http://$DOMAIN_NAME."
echo "If needed, you can complete the WordPress installation by visiting http://$DOMAIN_NAME/installer.php."
echo "Note: DO NOT FORGET TO INSTALL AN SSL AND USE CLOUDFLARE!!"
echo "Script by rootlodge.com"
