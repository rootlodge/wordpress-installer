# Bash Script to Install Nginx, MariaDB, and WordPress

This Bash script automates the installation of Nginx, MariaDB, and WordPress on Ubuntu Linux. It also includes an option to automatically install an SSL certificate using Let's Encrypt.

## Requirements

- Ubuntu 20.04 or later
- Bash shell

## Usage

1. Download the following scripts:

```curl -O https://raw.githubusercontent.com/rootlodge/wordpress-installer/master/wp-installer.sh```
```curl -O https://raw.githubusercontent.com/rootlodge/wordpress-installer/master/installnginxconfig.sh```


2. Make the scripts executable:

```chmod +x wp-installer.sh```
```chmod +x installnginxconfig.sh```

3. Run the script with root privileges:

```sudo ./wp-installer.sh```

4. Follow the prompts to enter your domain name and other information.

5. If you chose to install an SSL certificate, the script will automatically configure Nginx to use HTTPS.

6. Visit your website at `https://your-domain.com`.

## Credits

This script was created by rootlodge.com.
