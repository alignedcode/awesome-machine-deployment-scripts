#!/bin/bash

# VARIABLES
PROJECT_DOMAIN_RELEASE="acvod.alignedcode.com"
PROJECT_DOMAIN_STAGING="acvod-staging.alignedcode.com"
PROJECT_DOMAIN_DEV="acvod-dev.alignedcode.com"


echo -e "\033[32m[===============================================================]\033[m"
echo -e "\033[32m[STEP 0. UPDATE AND INIT SYSTEM]\033[m"
echo -e "\033[32m[===============================================================]\033[m"

# Update system
sudo apt-get update                 # check updates
sudo apt-get upgrade                # install updates
echo -e "\033[32mThe system has been updated!\033[m" && echo

# Create swap file
free -h
sudo fallocate -l 5G /swapfile      # create swapfile
sudo chmod 600 /swapfile            # leave access only to the superuser
sudo mkswap /swapfile               # create swap filesystem
sudo swapon /swapfile               # enable swapfile
free -h
echo -e "\033[32mThe swap section has been created!\033[m" && echo

# make the swap file work after the system reboot
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab 

# Grant access to the firewall for ssh connection
sudo ufw allow 'OpenSSH'

# Enable firewall
sudo ufw allow 5432/tcp
sudo ufw enable
echo -e "\033[32mThe firewall has been enabled!\033[m" && echo


echo -e "\033[32m[===============================================================]\033[m"
echo -e "\033[32m[STEP 1. INSTALL NGINX]\033[m"
echo -e "\033[32m[===============================================================]\033[m"

# Install Nginx
sudo apt install nginx

# Grant access to the firewall for Nginx
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'

# Check firewall status
sudo ufw status

# Check nginx status
systemctl status nginx | cat
echo -e "\033[32mThe Nginx has been installed!\033[m" && echo


echo -e "\033[32m[===============================================================]\033[m"
echo -e "\033[32m[STEP 2. CONFIGURATING NGINX AND SSL]\033[m"
echo -e "\033[32m[===============================================================]\033[m"

# Install an ssl certificate provider 
sudo apt-get install certbot
sudo apt-get install python3-certbot-nginx

# Update nginx config
cp nginx/nginx.conf /etc/nginx/nginx.conf

# Checking the validity of nginx.conf and restart nginx
nginx -t && nginx -s reload

sudo certbot --nginx -d $PROJECT_DOMAIN_DEV     --register-unsafely-without-email
sudo certbot --nginx -d $PROJECT_DOMAIN_STAGING --register-unsafely-without-email
sudo certbot --nginx -d $PROJECT_DOMAIN_RELEASE --register-unsafely-without-email

# Update nginx config
cp nginx/ssl.nginx.conf /etc/nginx/nginx.conf

# Checking the validity of nginx.conf and restart nginx
nginx -t && nginx -s reload


echo -e "\033[32m[===============================================================]\033[m"
echo -e "\033[32m[STEP 3. INSTALL DOCKER]\033[m"
echo -e "\033[32m[===============================================================]\033[m"

# Set up the docker repository
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
echo -e "\033[32mThe Docker has been installed!\033[m" && echo


echo -e "\033[32m[===============================================================]\033[m"
echo -e "\033[32m[STEP 4. Create automatically Renew Let's Encrypt Certificates]\033[m"
echo -e "\033[32m[===============================================================]\033[m"

line="0 12 * * * /usr/bin/certbot renew --quiet"
(crontab -u $(whoami) -l; echo "$line" ) | crontab -u $(whoami) -
echo -e "\033[32mCron job has been set!\033[m" && echo
