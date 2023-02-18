# DynDNS Service
A DynDNS service enables an Internet connection with a dynamic IP address - most private Internet connections - to be reached via URL. An account must be created with a DynDNS provider (e.g. twodns.de/). This account is entered in the router. As the router registers a change of the public IP address, this new IP address is transmitted to the DynDNS service.

After registration, a separate URL should be created for each service that is run with Docker. It should be mentioned here that such services sometimes also allow wildcard subdomains. However, I will leave this out of this tutorial to make it easier to understand. For the creation of Seafile and Plex gehe we need these web addresses (URL):

  - seafile.dyndns.de
  - plex.dyndns.de
# Set a fixed IP address for the server in the router

To ensure that the server is always reachable, the computer must always have the same IP address in its own network. For this purpose, the router (e.g. Fritzbox) is set so that the server always receives a fixed IP (e.g. 192.168.178.40).

# Port Releases in the Router

To ensure that requests from the network are not blocked by the firewall, certain ports must be released for requests from outside to the IP address of the router. The following ports are important:

- Port 80 (TCP)    	- mandatory for HTTP requests.
- Port 443 (TCP)   	- mandatory for HTTPS requests
- Port 32400 (TCP) 	- optionally necessary for Plex, so that Plex apps (e.g. FireStick, some TVs) are working.
- Port 32400 (UDP)	- optionally necessary for Plex, so that Plex apps (e.g. FireStick, some TVs) are working.

# Rebind protection

In many routers, you can set a rebind protection. This prevents requests to the URL (e.g. seafile.dyndns.de) from your own network from being routed over the Internet - i.e. they only run in your own network. 

# Install Docker and Docker Compose (already available on Ubuntu)

The installation is only necessary if Docker and Docker-Compose are not installed on the system yet. For testing the installed version can be displayed with the command docker -v and docker-compose -v. If no error message is displayed, the following steps can be skipped.

	apt-get update && apt-get -y upgrade

	apt-get install -y curl && curl https://get.docker.com | bash

	sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - apt-key fingerprint 0EBFCD88

	apt-get install docker-compose

	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	apt-get update

	apt-get install -y docker-ce

	apt-get install docker-compose
  
# Basic settings

Create folder /home/docker

	sudo mkdir -pv /home/docker

Clone Repository

	cd /home/docker
	sudo git clone https://github.com/strahli30/HowTo-use-Docker-Seafile-Plex-NGINX.git && \
	sudo mv HowTo-use-Docker-Seafile-Plex-NGINX/* ./ && \
	sudo rm -r HowTo-use-Docker-Seafile-Plex-NGINX/

Start basic installation (create folder structure, install Webmin and davFS)

	sudo ./systemset.sh start

# NGINX | LetyEncrypt | Launch Watchtower

NGINX will manage incoming and outgoing traffic and use LetsEncrypt to obtain SSL certificates fully automatically and renew them as needed. Watchtower will keep all running Docker containers up to date. The entire package is started with one line:

	sudo docker-compose -f /home/docker/tools/docker-compose.yml up -d

# Seafile

Some manual work is necessary to start the Seafile container. First, the docker-compose.yml file must be adapted for the first start. After that, some Seafile config files have to be adapted and the docker-compose.yml file fine-tuned if necessary.

- Adjusting the docker-compose.yml file
		
		sudo nano /home/docker/seafile/docker-compose.yml 

	adapt the following lines:
	
		services:
		  db:
		  […]
		    environment:
		      - MYSQL_ROOT_PASSWORD=YourSecurePassword # change this password.
		  […]
		  seafile:
		  […]
		    environment:
		  […]
		      - DB_ROOT_PASSWD=YourSecurePassword # use the same password as above
		      - SEAFILE_ADMIN_EMAIL=admin # must be adapted - this is the user name.
		      - SEAFILE_ADMIN_PASSWORD=password # must be adapted - is the password
		      - SEAFILE_SERVER_HOSTNAME=seafile.dyndns.de # URL of DynDNS-Dienst
		      - VIRTUAL_HOST=seafile.dyndns.de # URL of DynDNS-Dienst
		      - LETSENCRYPT_HOST=seafile.dyndns.de # URL of DynDNS-Dienst
		      - LETSENCRYPT_EMAIL=meinewegwerfadresse@ich.de  # your mailadress

- now Seafile can start for the first time - without the detach flag "-d" to observe the complete start-up

		sudo docker-compose -f /home/docker/seafile/docker-compose.yml up
		
- after the complete start, the container is stopped with Ctrl + C and cleaned up with the following command:

		sudo docker-compose -f /home/docker/seafile/docker-compose.yml down

- Adjusting the docker-compose.yml 

	The following adaptation of the docker-compose.yml ensures that the database and config files are still stored on the SSD with the operating system while the data is stored on an HDD. It is important that the folder /mnt/hdd1/seafile-data exists. This folder will store all data on Seafile.

		sudo nano /home/docker/seafile/docker-compose.yml 
	
	adjust the following lines:
	
		services:
		[…]
  		  seafile:
		[…]
    		    volumes:
          	    #WICHTIG: bei erstem Start nur die oberste Zeile aktivieren
          	    #Ordner-Separierung kann dann nach zweiten Schritt beginnen
          	    #vor zweitem Start erste Zeile auskommentieren und dafür die folgende 
		    #Auskkommentierung löschen
	 	      #- ./app:/shared
		       - ./app/logs:/shared/logs
		       - ./app/seafile/ccnet:/shared/seafile/ccnet
		       - ./app/seafile/conf:/shared/seafile/conf
		       - ./app/seafile/seahub-data:/shared/seafile/seahub-data
		       - /mnt/hdd1/seafile-data:/shared/seafile/seafile-data

- for webDAV access to the files, copy the following file from the templates to the conf folder

		sudo cp /home/docker/seafile/config.files.seafile/seafdav.conf /home/docker/seafile/app/seafile/conf/

- some URL adjustments
		
	ccnet.conf:

		sudo nano /home/docker/seafile/app/seafile/conf/ccnet.conf
	
	Insert the following lines - do not change the rest of the file!
	
		# Change ONLY Service_URL to https and without PortNumber
		[General]
		SERVICE_URL = https://seafile.dyndns.de # Enter URL from DynDNS service
		
	seahub_settings.py:
	
		sudo nano /home/docker/seafile/app/seafile/conf/seahub_settings.py
		
	Insert the following lines - do not change the rest of the file!
	
		#ONLY change URL of DynDNS service from http to https
		FILE_SERVER_ROOT = "https://seafile.dyndns.de/seafhttp"

		#Insert this line with the URL of the DynDNS service
		SERVICE_URL = 'https://seafile.dyndns.de/seafhttp'
		
- Adjusting the Seafile settings

		sudo nano /home/docker/seafile/app/seafile/conf/seafile.conf
	
	Important: do not change the database section (starts from [database])! Add the following information:
			
		[fileserver]
		# tcp port for fileserver
		port = 8082

		# Set maximum upload file size to 4000M=4GB
		max_upload_size=40000

		# Set maximum download directory size to 4000M=4GB.
		max_download_dir_size=40000

		#Set uploading time limit to 10800s = 3h
		web_token_expire_time=10800

		[quota]
		# default user quota in GB, integer only
		default = 5

		[history]
		# set a default history length limit for all libraries. Default no limit 
		keep_days = 30 #days of history to keep

- Finally, restart Seafile and run it as a service

		sudo docker-compose -f /home/docker/seafile/docker-compose.yml up -d

# Plex

Some manual work is necessary to start the Plex container. First, the docker-compose.yml file must be changed for the first start. On the first start, a claim code is necessary so that the login to your own account works.

Call up plex.tv/claim/ copy the displayed code and paste it into the following file, among others
(Attention: Code is only valid for 4 minutes)

		sudo nano /home/docker/plex/docker-compose.yml

Add the following information:

	services:
	  plex:
	    [...]
	    volumes:
	    [...]
	      - <PATH to MEDIA files /mnt/hdd2/media...>:/data #the films are located here
	    [...]
	    environment:
	    [...]
	      - ADVERTISE_IP=http://plex.dyndns.de:32400/ # enter URL from DynDNS service
	      - VIRTUAL_PORT=32400
	      - VIRTUAL_HOST=plex.dyndns.de # Enter URL from DynDNS service
	      - LETSENCRYPT_HOST=plex.dyndns.de # Enter URL of DynDNS service
	      - LETSENCRYPT_EMAIL=meinewegwerfadresse@ich.de # your mail address
	       #only important when creating a new server to legitimise server gene plex.tv
	       #entry will be ignored if server is registered - can be commented out
	      - PLEX_CLAIM=claim-xxxx_XXXX-ssL #paste the code from plex.tv/claim/ completely here

Start Plex container and call it up in the browser after a few minutes - and ready hurray

	sudo docker-compose -f /home/docker/plex/docker-compose.yml up -d
