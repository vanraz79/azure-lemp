#!/bin/sh

# Update the system
yum update -y

# Use the temporary disk /dev/sdb1 for swap
mkswap -f /dev/sdb1
swapon /dev/sdb1

# Install MariaDB from official repos
echo '[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck = 1
enabled = 1' | tee /etc/yum.repos.d/mariadb.repo
yum install -y MariaDB-server MariaDB-client

# Download MariaDB configuration file
curl https://raw.githubusercontent.com/EgoAleSum/azure-lemp/master/resources/mariadb.cnf > /etc/my.cnf.d/server.cnf

# Start MariaDB and make it start at boot
#service mariadb start
#chkconfig mariadb start

# Install Nginx and PHP5-FPM
echo '[nginx]
name = nginx
baseurl = http://nginx.org/packages/centos/7/$basearch/
gpgcheck = 0
enabled = 1' | tee /etc/yum.repos.d/nginx.repo
yum install -y nginx php-fpm php-mysqlnd php-pdo php-intl

# Create the webroot
mkdir -p /www/html
chown nginx:nginx -R /www

# Fix SELinux permissions on the webroot
chcon -Rt httpd_sys_content_t /www

# Configure Nginx
rm -f /etc/nginx/conf.d/*.conf
curl https://raw.githubusercontent.com/EgoAleSum/azure-lemp/master/resources/nginx.conf > /etc/nginx/nginx.conf
curl https://raw.githubusercontent.com/EgoAleSum/azure-lemp/master/resources/default-site.conf > /etc/nginx/conf.d/default-site.conf

# Configure PHP
curl https://raw.githubusercontent.com/EgoAleSum/azure-lemp/master/resources/php.ini > /etc/php.ini

# Start Nginx and PHP
service nginx start
service php-fpm start

# Make Nginx and PHP start at boot
chkconfig nginx on
chkconfig php-fpm on
