# DynDNS Service
A DynDNS service enables an Internet connection with a dynamic IP address - most private Internet connections - to be reached via a URL. To do this, an account must first be created with a provider (e.g. twodns.de/). This account is then also entered in the router. As soon as the router registers a change of the public IP address, this new IP address is forwarded to the DynDNS service.

After registration, a separate URL should be created for each service that is to run with Docker. It should be mentioned here that such services sometimes also allow wildcard subdomains. However, I will leave this out of this tutorial to make it easier to understand. For the creation of Seafile and Plex gehe we need these web addresses (URL):

--> seafile.dyndns.de
--> plex.dyndns.de
