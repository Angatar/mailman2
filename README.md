# Lightweight (242Mb) useful mailman2 from buster-slim (Angatar> d3fk/mailman2)
A useful compact mailman2 + exim4 + apache2 container image based on Debian(10) buster-slim to easily create and manage your mailing lists (including web interfaces).

Debian buster is the latest Debian release that has packages of the so convenient mailman2. This container image intends to provide a stable and easy way to deploy a mailing lists manager with mailman2 and exim4. 

The containers deployed from the d3fk/mailman2 image have TLS enabled and configured and are also DKIM ready (generated and configured DKIM keys). It is also ready to make use of https (with generated self-signed or custom certificates). A basic container's web server health check is implemented.

## Get this image (d3fk/mailman2)
The best way to get this d3fk/mailman2 image is to pull the prebuilt image from the Docker Hub Registry.

The image is prebuilt from Docker hub with "automated build" option from the [code repository on Github](https://github.com/Angatar/mailman2).

image name **d3fk/mailman2**
```sh
$ docker pull d3fk/mailman2
```
Docker hub repository: https://hub.docker.com/r/d3fk/mailman2/


[![DockerHub Badge](https://dockeri.co/image/d3fk/mailman2)](https://hub.docker.com/r/d3fk/mailman2)

 
### Image tag d3fk/mailman2:latest

The **d3fk/mailman2:latest** image available from the Docker Hub is built automatically (automated build on each change of this [image code repository](https://github.com/Angatar/mailman2) + automated build triggered once per week) so that using the d3fk/mailman2:latest image ensures you to have the latest updated(including security fixes) and functional version available of mailman2, exim4 and apache in a lightweight Debian buster (Debian 10 slim version) till the end of the [LTS of this Debian release](https://wiki.debian.org/DebianReleases).
 
### Image tag d3fk/mailman2:stable 
In case you'd prefer a fixed version of this d3fk/mailman2 container to avoid any possible change in its behaviour, the d3fk/mailman2:stable image is also made available from the Docker hub. This image had a stable behaviour observed in production, so that it was freezed in a release of the code repo and built from the Docker hub by automated build. It won't be changed or rebuilt in the future (the code is available from the "releases" section of this [image code repository on GitHub](https://github.com/Angatar/mailman2)).

image:tag **d3fk/mailman2:stable**
```sh
$ docker pull d3fk/mailman2:stable
```

## ENVIRONMENT

- **`URL_HOST`** - the subdomain/domain of the web server on which the mailman web interfaces will be made available: used for the URL
- **`EMAIL_HOST`** - the email host name: the subdomain/domain that will be used by your lists for their email addresses
- **`MASTER_PASSWORD`** - the master password of the mailing lists - default is set to "example"
- **`LIST_ADMIN`** - the email address of the lists administrator - used to create the admin account
- **`LIST_LANGUAGE_CODE`** - default is set to english with the value: "en"
- **`URL_ROOT`** -  this env allows to add a root dir to mailman so that it is not obvious for bots. Don't forget the trailing slash or set it as empty string "" if the `URL_ROOT` has to be "`URL_HOST/`". The default value is set to "lists/"
- **`URL_PATTERN`** - Possible values are "https" and "http" ... for providing web interfaces preferably through https or not. can be useful to set it to "https" with an "https" ingress or reverse-proxy/load-balancer and letsencrypt certmanager for example - or by using a container embedded certificate with setting the next env var to "true" - default value set to "http"
- **`SSL_FROM_CONTAINER`** - If you want to go with https on `URL_PATTERN` you might want that the d3fk/mailman2 provides https connection (for other https possibilities see the advanced configuration section).In this case the mod_ssl is enabled and configured and a redirection from 80 to 443 in the container will be set automatically - The default value is set to "false" as a stringified boolean
- **`SSL_SELFSIGNED`** - Only acts if `SSL_FROM_CONTAINER` is set to "true". If `SSL_SELFSIGNED` is set to "true" a self-signed certificate is generated during deployment - If set to "false" it uses the existing certificates in the container without regeneration (allowing you to use your own SSL certificate) - default is set to "false" 
- **`ENABLE_SPF_CHECK`** - if you are not behind a load-balancer/reverse-proxy or if you can get the origin IP from your container it might be useful to enable SPF check to avoid identity usurpation of incoming emails. Enabling this option will use about 2.5Mb of additional disk space. This var is waiting for a stringified boolean and the default value is set to "false"


## Basic usage

The following `docker run` is just an example, you have to define your own environment variables according to your DNS configuration and your requirements: 

```sh
$ docker run --rm -d --name mailman \
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

The logs will display the deployment steps of the container and provide you in the end with a **valid DKIM public key** value and the **DKIM txt record** that can be added to your DNS records to enable DKIM check for your mailman mailing list server.

In case you didn't yet configured your DNS for emails and web server, your new mailman2 web server is at least already reachable from http://localhost (welcome text) and if you let the `URL_ROOT` at its default value ("lists/") the mailman admin interface can be reached from (http://localhost/lists/admin/)

The mailing lists cannot be used or created from your localhost since they require a valid `EMAIL_HOST` name to be configured. For details on DNS configuration see the following section...


## DNS configuration
Several records on your DNS are required to make mailman, exim4 and the web interfaces work properly (the txt records are optional but good practice).
- 1 **A** record for your domain or subdomain to declare your web interfaces that will allows to manage your mailing lists. This record has to correspond to your `URL_HOST` and has to point to the IP of the server running this container or to the IP of your load-balancer in case your IT is scaled on several nodes.
- If your `URL_HOST` and `EMAIL_HOST` are different, you'll also need an **A** record for your `EMAIL_HOST` to declare the subdomain/domain that will be associated to your email server/load-balancer/reverse-proxy.
- 1 **PTR** record that will redirect your `EMAIL_HOST` IP address to your `EMAIL_HOST` name for reverse DNS lookups.
- 1 **MX** record to declare that your `EMAIL_HOST` is authorised to send email for your domain/subdomain name.
- 1 **TXT** record to declare your DKIM public key (the txt record including the public key is provided in the container logs)
- 1 **TXT** record to define your server SPF check rules so that you'll avoid the usurpation of the identity of your email server.
- 1 **TXT** record for your DMARC. It requires that your DKIM and SPF records are properly configured. 


## Advanced configuration
The deployed d3fk/mailman2 containers have default a configuration aiming at improving security and email deliverability but may be optimized or changed. If you require a different advanced configuration you can easily overwrite the default configuration files with custom config files by using docker/kubernetes volumes.

### Data persistence
Within this container image are defined the following volumes of interest which make create by docker local anonymous volumes for important data:
- VOLUME /var/log/mailman for the logs of mailman
- VOLUME /var/log/exim4 for the logs of exim4
- VOLUME /var/log/apache2 for apache2 logs
- VOLUME /var/lib/mailman/archives for the mailman
- VOLUME /var/lib/mailman/lists to create a persistence for the mailman mailing lists created
- VOLUME /etc/exim4/tls.d to conserve the DKIM certificate over new deployments


As they are anonymous local volumes, docker handle where the files are stored by default.
The data stored in these volumes can be used from other containers (e.g.: for log management) by using the `--volumes-from` docker option
Be aware that in case you use the `docker run --rm` option the volumes will be removed when the container is stopped.

In order to create a better persistence of the data of interest with docker you can use the "named volumes" capabilities.
In case you whish to control the location of these data on your host with docker you can use the "host volumes" types.

So, if you require to keep data persistence on the future mailman container deployments with kubernetes or docker you have to use the volumes capabilities e.g.: 

```sh
$ docker create volume apachelogs
$ docker run --rm -d --name mailman \
             -p 80:80 -p 443:443 -p 25:25 -p 465:465 -p 587:587 \
             -e URL_HOST=lists.example.com \
             -e EMAIL_HOST=mails.example.com \
             -e LIST_ADMIN=youremail@example.com \
             -e MASTER_PASSWORD="example" \
             -e URL_PATTERN="https" \
             -e SSL_FROM_CONTAINER="true" \
             -e SSL_SELFSIGNED="true" \
             -v apachelogs:/var/log/apache2 \
             -v $(pwd)/lists:/var/lib/mailman/lists \
             -v $(pwd)/dkimcert:/etc/exim4/tls.d \
             d3fk/mailman2
```

### mailman configuration
In order to improve the deliverability and security of the mailing lists, the mailman mailing lists are set by default to be list members only(non-members posts have to be validated by the administrator) and the FROM is munged (in regards to DMARC).

Some default options are set to be convenient in most of cases (e.g: file attachement enabled, automatic discarding of held messages after 15 days ... )

Most of all the mailman configuration can be changed from the web interfaces of each created mailing lists. However in case you need to change the default behaviour for all the future mailing list creation you can simply edit the mailman configuration by replacing corresponding config files with a simple docker or k8s volume.

### Ports to expose
This container exposes the following ports
- 80  for HTTP connection to the web interfaces
- 443 for HTTPS access to the web interfaces
- 25  for SMPT connection
- 465 for TLS on connect as explained in [the exim documentation](https://www.exim.org/exim-html-current/doc/html/spec_html/ch-encrypted_smtp_connections_using_tlsssl.html)
- 587 for standard SMTPS

However you are free to map these container ports to the corresponding ports(might be other ports e.g.:8080) on your server according to your configuration (e.g.: do not open 443 if you only go with http for the web interfaces)

### Setting HTTPS
There are 3 main ways to make use of https with this container:

- URL_PATTERN="https" but SSL_FROM_CONTAINER="false" so that the container cannot be directly exposed with https and the SSL cert is managed elsewhere (eg: load balancer, reverse-proxy, ingress ....) and the connection between this load balancer or whatever and the mailman2 container is made through HTTP.
- URL_PATTERN="https", SSL_FROM_CONTAINER="true" but SSL_SELFSIGNED="true"  so that the container is managing SSL from the inside with a generated self-signed certificate so that it could directly be exposed with https but with an error displayed on most browsers(due to self-signed cert) so in this case it is better to have a valid SSL certifiacte managed elsewhere (eg: load balancer, reverse-proxy, ingress ....) and the connection between this load balancer or whatever and the mailman2 container is made through HTTPS with the self-signed certificate.
-  URL_PATTERN="https" and SSL_FROM_CONTAINER="true" and SSL_SELFSIGNED="false" this allows you to use a custom certificate by adding the couple pem cert + key through the use of volumes on the following paths:

```sh
/etc/ssl/certs/ssl-cert-snakeoil.pem
/etc/ssl/private/ssl-cert-snakeoil.key
```

So, the docker run should looks like the following:

```sh
$ docker run --rm -d --name mailman \
             -p 80:80 -p 443:443 -p 25:25 -p 465:465 -p 587:587 \
             -e URL_HOST=lists.example.com \
             -e EMAIL_HOST=mails.example.com \
             -e LIST_ADMIN=youremail@example.com \
             -e MASTER_PASSWORD="example" \
             -e URL_PATTERN="https" \
             -e SSL_FROM_CONTAINER="true" \
             -e SSL_SELFSIGNED="false" \
             -v PATH/customcert.pem:/etc/ssl/certs/ssl-cert-snakeoil.pem \
             -v PATH/customcertkey.key:/etc/ssl/private/ssl-cert-snakeoil.key \
             - ...
```


## Using with Kubernetes

You can use as templates the YAML files provided in the k8s directory (deployment, service, load-balancer, ingress) of this repository for a fast set up with kubernetes.

