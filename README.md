# Lightweight (312Mb) useful mailman2 from buster-slim (Angatar> d3fk/mailman2)
A useful compact mailman2 + exim4 + apache2 container based on Debian(10) buster-slim to easily create and manage your mailing lists (including web interfaces).

Debian buster is the latest Debian release that has packages of the so convenient mailman2. This container image intends to provide a stable and easy way to deploy a mailing lists manager with mailman2 and exim4. 

The containers deployed from the d3fk/mailman2 image have TLS enabled and configured and are also DKIM ready (generated and configured DKIM keys). It is also ready to make use of https (with generated self-signed or custom certificates).

## Get this image (d3fk/mailman2)
The best way to get this d3fk/mailman2 image is to pull the prebuilt image from the Docker Hub Registry.

The image is prebuilt from Docker hub with "automated build" option from this repository.

image name **d3fk/mailman2**
```sh
$ docker pull d3fk/mailman2
```
Docker hub repository: https://hub.docker.com/r/d3fk/mailman2/
 
### Image tag d3fk/mailman2:latest

The **d3fk/mailman2:latest** image available from the Docker Hub is built automatically (automated build on each change of this repo + automated build triggered once per week) so that using the d3fk/mailman2:latest image ensures you to have the latest updated(including security fixes) and functional version available of mailman2, exim4 and apache in a lightweight Debian buster (Debian 10) till the end of the [LTS of this Debian release](https://wiki.debian.org/DebianReleases).
 
### Image tag d3fk/mailman2:stable (comming soon) 
In case you'd prefer a fixed version of this d3fk/mailman2 container to avoid any possible change in its behaviour, the d3fk/mailman2:stable image is also made available from the Docker hub. This image had a stable behaviour observed in production, so that it was freezed in a release of this repo and built from the Docker hub by automated build. It won't be changed or rebuilt in the future (the code is available from the "releases" section of this code repository on GitHub).

image:tag **d3fk/mailman2:stable**
```sh
$ docker pull d3fk/mailman2:stable
```

## ENVIRONMENT

- `URL_HOST` - *the subdomain/domain of the web server on which the mailman web interfaces will be made available: used for the URL*
- `EMAIL_HOST` - *the email host name: the subdomain/domain that will be used by your lists for their email addresses*
- `MASTER_PASSWORD` - *the master password of the mailing lists - default is set to "example"*
- `LIST_ADMIN` - *the email address of the lists administrator - used to create the admin account* 
- `LIST_LANGUAGE_CODE` - *default is set to english with the value: "en"*
- `URL_ROOT` -  *this env allows to add a root dir to mailman so that it is not obvious for bots. Don't forget the trailling slash or set it as empty string "" if the `URL_ROOT` has to be "`URL_HOST/`". The default value is set to "lists/"*
- `URL_PATTERN` - *Possible values are "https" and "http" ... for providing web interfaces preferably through https or not. can be usefull to set it to "https" with an "https" ingress or reverse-proxy/load-balancer and letsencrypt certmanager for example - or by using a container embedded certificate with setting the next env var to "true" - default value set to "http"*
- `SSL_FROM_CONTAINER` - *If you want to go with https on `URL_PATTERN` you might want that the d3fk/mailman2 provides https connection (for other https possibilities see the advanced configuration section)- default value set to "false" as a stringified boolean*
- `SSL_AUTOSIGNED` - *Only acts if `SSL_FROM_CONTAINER` is set to "true". If `SSL_AUTOSIGNED` is set to "true" an autosigned certificate is generated during deployment - If set to "false" it uses the exisiting certificates in the container without regeneration (allowing you to use your own SSL certificate) - default is set to "false"* 
- `ENABLE_SPF` - *if you are not behind a load-balancer/reverse-proxy or if you can get the origin IP from your container it might be useful to enable SPF check to avoid identity usurpation of incomming emails. Enabling this option will use about 2.5Mb of additional disk space. This var is waiting for a stringified boolean and the default value is set to "false"*


## Basic usage

The following `docker run` is just an example, you have to define your own environment variables according to your DNS configuration and your requirements: 

```sh
$ docker run --rm -d -name mailman \
             -p 80:80 -p 25:25 -p 465:465 \
             -e URL_HOST=lists.example.com \
             -e EMAIL_HOST=mails.example.com \  
             -e LIST_ADMIN=youremail@example.com \
             -e MASTER_PASSWORD="example" \ 
             d3fk/mailman2
```

Then visit the logs of the mailman container you have created:

```sh
$ docker logs mailman 
```

The logs will display the deployment steps of the container and provide you in the end with a valid DKIM public key value and the DKIM txt record that can be added to your DNS records to enable DKIM check for your mailman mailing list server.

In case you didn't yet configured your DNS for emails and web server, your new mailman2 web server is at least already reachable from http://localhost (welcome text) and if you let the `URL_ROOT` at its default value ("lists/") the mailman admin interface can be reached from (http://localhost/lists/admin/)

The mailing lists cannot be used or created from your localhost since they require a valid `EMAIL_HOST` name to be configured. For details on DNS configuration see the following section...


## DNS configuration
Several records on your DNS are required to make mailman, exim4 and the web interfaces work properly (the txt records are optional but good practice).
- 1 **A** record for your domain or subdomain to declare your web interfaces that will allows to manage your mailing lists. This record has to correpond to your `URL_HOST` and has to point to the IP of the server running this container or to the IP of your load-balancer in case your IT is scalled on several nodes.
- If your `URL_HOST` and `EMAIL_HOST` are different you'll also need an **A** record for your `EMAIL_HOST` to declare the subdomain/domain that will be associated to your email server/load-balancer/reverse-proxy.
- 1 **PTR** record that will redirect your `EMAIL_HOST` IP address to your `EMAIL_HOST` name for reverse DNS lookups.
- 1 **MX** record to declare that your `EMAIL_HOST` is authorised to send email for your domain/subdomain name.
- 1 **TXT** record to declare your DKIM public key (the txt record including the public key is provided in the container logs)
- 1 **TXT** record to define your server SPF check rules so that you'll avoid the usurpation of the identity of your email server.
- 1 **TXT** record for your DMARC. It requires that your DKIM and SPF records are properly configurated. 


## Advanced configuration
The deployed d3fk/mailman2 containers have default configuration set to improve security and email deliverability. If you require a different advanced configuration you can easilly overide the default configuration files with custom config files by using docker/kubernetes volumes.

### persistent data
comming soon

### mailman configuration
in order to improve the deliverability and security of the mailing lists

Most of the mailman configuration can be changed from the web interface of each created mailing lists. However in case you need to change the default behaviour for the future mailing list creation you simply can edit the mailan configuration by replacing corresponding config files with using a simple docker volume.

The default mailman configuration for email sending is set to wrap in order to improve the deliverabelity of the email sent through the mailing lists.

### What are the ports to open
This container exposes the following ports
- 80 for HTTP connection to the web interfaces
- 443 for HTTPS access to the web interfaces
- 25 for SMPT connexion
- 465 for TLS first connection as explained in the exim documentation
- 587 for standard TLS -SMTP

feel free to map these container ports to corresponding ports on your server according to your configuration (e.g: do not open 443 if you only goes in http)

### setting https


## Using with Kubernetes

You can use as templates the YAML files provided in the k8s directory (deployment, service,load-balancer, ingress) of this repository for a fast set up with kubernetes.

to be continued...
