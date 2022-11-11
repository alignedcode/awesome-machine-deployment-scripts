# Scripts for configuring and deploying (AWS, DigitalOcean, etc.)


Scripts for configuring and deploying DEV, STAGING, RELEASE environments on a dedicated server (AWS, DigitalOcean, etc.)


## Getting started

1. Install Ubuntu LTS on your machine.
2. Open the terminal by connecting via ssh or using the GUI, on behalf of a superuser or a user with superuser rights
3. Open the generate-nginx-configs script files.sh and init-system.sh and edit the variables associated with domain names and ports


Open generate-nginx-configs.sh file:
```
nano generate-nginx-configs.sh
```

Change the domain names by analogy <br/>

<b style="color: red">ATTENTION!</b> The order of variable domains in the array is important: RELEASE_DOMAIN, STAGING_DOMAIN, DEV_DOMAIN

```
PROJECT_DOMAINS=(
    "acvod.alignedcode.com" 
    "acvod-staging.alignedcode.com" 
    "acvod-dev.alignedcode.com"
)
```

Depending on the project (Client or Server), set the port values.

| Project type | Ports template |
|--------------| ---------------|
| CLIENT       | 808*           |
| SERVER       | 800*           |

<b style="color: red">ATTENTION!</b> The order of variable ports in the array is important: RELEASE_DOMAIN_PORT, STAGING_DOMAIN_PORT, DEV_DOMAIN_PORT

```
PROJECT_PORTS=(
    "8082" 
    "8081" 
    "8080" 
)
```


Open init-system.sh file:
```
nano init-system.sh
```

Change the domain names by analogy:
```
PROJECT_DOMAIN_RELEASE="acvod.alignedcode.com"
PROJECT_DOMAIN_STAGING="acvod-staging.alignedcode.com"
PROJECT_DOMAIN_DEV="acvod-dev.alignedcode.com"
```

4. Execute these commands:
```
cd existing_repo
git clone https://gitlab.com/aligned-code/deployments-configs/machine.git
cd machine
./generate-nginx-configs.sh
./init-system.sh
```

5. Create automatically Renew Let's Encrypt Certificates

- Open the crontab file
```
crontab -e
```
- Add the certbot command to run daily. In this example, we run the command every day at noon. The command checks to see if the certificate on the server will expire within the next 30 days, and renews it if so. The --quiet directive tells certbot not to generate output.
```
0 12 * * * /usr/bin/certbot renew --quiet
```
