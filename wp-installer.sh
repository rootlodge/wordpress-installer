#!/bin/bash

# Get domain name from user
read -p "Enter domain name: " DOMAIN_NAME

# Install necessary packages
apt-get update
apt-get install -y nginx mariadb-server php8.2 php8.2-fpm php8.2-mysql php8.2-curl php8.2-gd php8.2-intl php8.2-mbstring php8.2-soap php8.2-xml php8.2-xmlrpc php8.2-zip certbot

# Configure database
read -p "Enter database name: " DATABASE_NAME
read -p "Enter database user: " DATABASE_USER
read -sp "Enter database password: " DATABASE_PASSWORD
echo -e "Y\n$DATABASE_PASSWORD\n$DATABASE_PASSWORD\nY\nY\nY\nY\nEOF" | mysql_secure_installation
mysql -e "CREATE DATABASE $DATABASE_NAME; GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$DATABASE_USER'@'localhost' IDENTIFIED BY '$DATABASE_PASSWORD'; FLUSH PRIVILEGES;"

# Download and configure WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rm latest.tar.gz
chown -R www-data:www-data wordpress
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i "s/database_name_here/$DATABASE_NAME/g" wordpress/wp-config.php
sed -i "s/username_here/$DATABASE_USER/g" wordpress/wp-config.php
sed -i "s/password_here/$DATABASE_PASSWORD/g" wordpress/wp-config.php

# Install SSL Certificate
read -p "Do you want to install an SSL certificate for your domain? [Y/N]: " SSL_INSTALL

if [[ $SSL_INSTALL =~ ^[Yy]$ ]]; then
    # Install SSL Certificate
    echo "Installing SSL Certificate..."
    certbot certonly --nginx --agree-tos --email $ADMIN_EMAIL -d $DOMAIN_NAME
    # Restart Nginx
    systemctl stop nginx
    
    echo "SSL certificate has been installed and Nginx configuration has been updated."
fi

echo "WordPress has been installed on your server. Please go to https://$DOMAIN_NAME to complete the installation process."

# Ask user if they want to install Nginx server block configuration
read -p "Do you want to install the Nginx server block configuration for $DOMAIN_NAME? [Y/N]: " SERVER_BLOCK_INSTALL

if [[ $SERVER_BLOCK_INSTALL =~ ^[Yy]$ ]]; then
    # Launch the Nginx server block configuration script
    bash installnginxconfig.sh $DOMAIN_NAME
else
    echo "Nginx server block configuration was not installed."
fi

# Credits
echo "Installer script created by rootlodge.com"
echo "Don't forget to start NGINX if needed.
