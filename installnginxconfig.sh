#!/bin/bash

# Get user input for domain name
read -p "Enter your domain name: " DOMAIN_NAME

# Check if user has SSL installed
read -p "Do you have an SSL certificate installed? (y/n) " SSL_INSTALLED

if [[ $SSL_INSTALLED == "y" ]]; then
  # Get user input for SSL provider
  read -p "Is your SSL certificate installed by Let's Encrypt or Certbot? (letsencrypt/certbot) " SSL_PROVIDER
  
  if [[ $SSL_PROVIDER == "letsencrypt" ]]; then
    # Create nginx server block config for Let's Encrypt SSL
    cat > /etc/nginx/sites-available/$DOMAIN_NAME <<EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN_NAME;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;

    root /var/www/html/wordpress;
    index index.php;

    # PHP-FPM Configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    # Nginx Cache Configuration
    location ~* \.(jpg|jpeg|gif|png|css|js|ico)$ {
        expires 30d;
        add_header Pragma public;
        add_header Cache-Control "public";
    }

    # WordPress Permalink Configuration
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    # Deny Access to Hidden Files
    location ~ /\. {
        deny all;
    }
}
EOF

  elif [[ $SSL_PROVIDER == "certbot" ]]; then
    # Create nginx server block config for Certbot SSL
    cat > /etc/nginx/sites-available/$DOMAIN_NAME <<EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN_NAME;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;

    root /var/www/html/wordpress;
    index index.php;

    # PHP-FPM Configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    # Nginx Cache Configuration
    location ~* \.(jpg|jpeg|gif|png|css|js|ico)$ {
        expires 30d;
        add_header Pragma public;
        add_header Cache-Control "public";
    }

    # WordPress Permalink Configuration
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    # Deny Access to Hidden Files
    location ~ /\. {
        deny all;
    }
}
EOF

  else
    echo "Invalid SSL provider entered."
    exit 1
  fi

else
  # Create nginx server block config without SSL
  cat > /etc/nginx/sites-available/$DOMAIN_NAME <<EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;

    root /var/www/html/wordpress;
    index index.php;

    # PHP-FPM Configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    # Nginx Cache Configuration
    location ~* \.(jpg|jpeg|gif|png|css|js|ico)$ {
        expires 30d;
        add_header Pragma public;
        add_header Cache-Control "public";
    }

    # WordPress Permalink Configuration
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    # Deny Access to Hidden Files
    location ~ /\. {
        deny all;
    }
}
}
EOF

fi

# Enable nginx server block config
ln -s /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/$DOMAIN_NAME

# Enable & Restart nginx service
systemctl enable nginx
systemctl restart nginx

# Enable MariaDB/MySQL service to start on boot
systemctl enable mariadb

# Enable PHP service to start on boot
systemctl enable php8.2-fpm

echo "Nginx server block configuration for $DOMAIN_NAME has been installed."
