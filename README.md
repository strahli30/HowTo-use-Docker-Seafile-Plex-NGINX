# DynDNS Service
A DynDNS service enables an Internet connection with a dynamic IP address - most private Internet connections - to be reached via a URL. To do this, an account must first be created with a provider (e.g. twodns.de/). This account is then also entered in the router. As soon as the router registers a change of the public IP address, this new IP address is forwarded to the DynDNS service.

After registration, a separate URL should be created for each service that is to run with Docker. It should be mentioned here that such services sometimes also allow wildcard subdomains. However, I will leave this out of this tutorial to make it easier to understand. For the creation of Seafile and Plex we need these web addresses (URL):

  - seafile.dyndns.de
  - plex.dyndns.de
# Set a fixed IP address for the server in the router

To ensure that the server can always be reached reliably, the computer must always have the same IP address in its own network. For this purpose, the router (e.g. Fritzbox) is set so that the server always receives a fixed IP (e.g. 192.168.178.40).

# Port Releases in the Router

So that requests from the network are not blocked by the firewall, certain ports must be released for requests from outside to the IP address of the router. The following ports are important:

- Port 80 (TCP) - mandatory for HTTP requests.
- Port 443 (TCP) - mandatory for HTTPS requests
- Port 32400 (TCP) - optionally necessary for Plex, so that Plex apps (e.g. FireStick) can work.
- Port 32400 (UDP) - optionally required for Plex to work (e.g. FireStick)

# Rebind protection

In many routers you can set a rebind protection for the shares and accesses to services. This ensures that requests to the URL (e.g. seafile.dyndns.de) from your own network are not routed via the internet - i.e. only run in your own network.

# Install Docker and Docker Compose (already available on Ubuntu)

This procedure is only necessary if Docker and Docker-Compose are not already installed on the system. To test, the installed version can be displayed with the command docker -v and docker-compose -v. If no error message appears here, the following steps can be omitted.

	apt-get update && apt-get -y upgrade
	apt-get install -y curl && curl https://get.docker.com | bash
	sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - apt-key fingerprint 0EBFCD88
	apt-get install docker-compose
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt-get update
	apt-get install -y docker-ce
	apt-get install docker-compose
  
