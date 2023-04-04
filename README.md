# Scripts for configuring and deploying to Ubuntu server (AWS, DigitalOcean, etc.)

Scripts for configuring and deploying environments on a dedicated Ubuntu server (AWS, DigitalOcean, etc.)


## Getting started

1. Install Ubuntu LTS on your machine.
2. Create DNS domain name records for the environments you need.
3. Open the terminal by connecting via ssh or using the GUI, on behalf of a superuser or a user with superuser rights.
4. Clone current repository.

```bash
git clone https://github.com/alignedcode/awesome-machine-deployment-scripts.git
```

5. Go to the cloned directory and edit the environment configuration file `environment.config`

```bash
cd awesome-machine-deployment-scripts 
nano environment.config
```

##### Edit the array with the domain names of the environments
For example, the set of domain names for 3 environments (production, staging, dev) can be as follows

```
DOMAINS=(
    "acvod.alignedcode.com" 
    "acvod-staging.alignedcode.com" 
    "acvod-dev.alignedcode.com"
)
```

##### Edit the array with the environment ports
Depending on the project (Client application or Server application), set the port values.

| Project type | Ports template |
|--------------| ---------------|
| CLIENT       | 808*           |
| SERVER       | 800*           |

For example, the set of ports for 3 environments (production, staging, dev) can be as follows

```
PROJECT_PORTS=(
    "8082" 
    "8081" 
    "8080" 
)
```

> **Warning** <br/>
> The order in which domain names and ports are declared is important.
> Each position in the array of domain names corresponds to a position in the array of ports

6. Run the script run.sh with superuser (root) rights
```bash
sudo ./run.sh
```

If the command is not found, make the script an executable file
```bash
chmod u+x ./run.sh
sudo ./run.sh
```

> **Info** <br/>
> During the execution of the script, agree with everything, prescribing Y or simply pressing Enter

## run.sh

Combines the main scripts to run in the right order

#### Steps
- Creating configuration files for nginx
- Configuring an Ubuntu server using previously generated nginx configuration files

## generate-nginx-configs.sh
Based on the list of domain names and ports from the configuration file, generates two 
configuration files for nginx: for 80 and 443 ports (http and https)

To run only this one, use:
```bash
sudo ./generate-nginx-configs.sh
```

## init-system.sh
Performs the initial configuration of Ubuntu server

- Installs updates
- Configures the swap partition
- Setup and enable firewall
- Configures Nginx using previously generated configuration files and generates SSL certificates
- Installs docker
- Sets up a scheduled task to update SSL certificates

To run only this one, use:
```bash
sudo ./init-system.sh
```
