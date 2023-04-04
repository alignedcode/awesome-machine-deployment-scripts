#!/bin/bash

. ./environment.config

echo -e "\033[32m[==================================================================]\033[m"
echo -e "\033[32m[ generate-nginx-configs.sh                                        ]\033[m"
echo -e "\033[32m[                                                                  ]\033[m"
echo -e "\033[32m[ Based on the list of domain names and ports from the config file,]\033[m"
echo -e "\033[32m[ generates two config files for nginx: for 80 and 443 ports       ]\033[m"
echo -e "\033[32m[                                                                  ]\033[m"
echo -e "\033[32m[ Author: Andrei Petrov <andrei.petrov@alignedcode.com>            ]\033[m"
echo -e "\033[32m[==================================================================]\033[m"
echo -e ""

#=======================================================================================
#
#
# ATTENTION! WE DO NOT CHANGE THE SCRIPT FURTHER
#
#
#=======================================================================================

__nginx="
user root;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format main '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                    '\$status \$body_bytes_sent \"\$http_referer\" '
                    '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;   

    server {
        listen       80;
        server_name  '';
        gzip_static on;

        location / {
            return 301 https://\$server_name\$request_uri;
        }
    }
"

__nginx_close="
}
"

echo -e "\033[32m[===============================================================]\033[m"
echo -e "\033[32m[                     NGINX CONFIG GENERATOR                    ]\033[m"
echo -e "\033[32m[===============================================================]\033[m"
echo -e " Starting the generations..." && echo

# Delete nginx folder, if there is one
rm -r nginx
# Create ndinx folder
mkdir nginx

__nginx_ssl="$__nginx"
__nginx_no_ssl="$__nginx"

for i in "${!DOMAINS[@]}"
do

server_record="
    server {
        listen       80;
        server_name  ${DOMAINS[$i]};
        gzip_static on;

        location / {
            proxy_pass http://127.0.0.1:${PORTS[$i]}\$request_uri;
        }
    }
"

server_record_ssl="
    server {
        listen       443 ssl;
        server_name  ${DOMAINS[$i]};
        ssl_certificate /etc/letsencrypt/live/${DOMAINS[$i]}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${DOMAINS[$i]}/privkey.pem;
        
        add_header Strict-Transport-Security \"max-age=31536000\";
        gzip_static on;

        location / {
            proxy_pass http://127.0.0.1:${PORTS[$i]}\$request_uri;
        }
    }
"

__nginx_no_ssl="${__nginx_no_ssl}${server_record}"
__nginx_ssl="${__nginx_ssl}${server_record}${server_record_ssl}"
done

echo "$__nginx_no_ssl$__nginx_close" >> nginx/nginx.conf
echo "$__nginx_ssl$__nginx_close" >> nginx/ssl.nginx.conf

echo -e "\033[32mNginx config files generation completed successfully!\033[m" && echo
