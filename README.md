# Lightweight (312Mb) useful mailman2 from buster-slim (Angatar> d3fk/mailman2)
A useful compact mailman2 + exim4 + apache container based on debian(10) buster-slim to easily create and manage your mailing lists (including web interfaces).

Debian buster is the latest Debian release that contains the so convenient mailman2. This container intends to provide a stable and easy way to deploy a mailing lists manager with mailman2 and exim4. 

## Get this image (d3fk/mailman2)
The best way to get this d3fk/mailman2 image is to pull the prebuilt image from the Docker Hub Registry.

The image is prebuilt from Docker hub with "automated build" option from this repository.

image name **d3fk/mailman2**
```sh
$ docker pull d3fk/mailman2
```
Docker hub repository: https://hub.docker.com/r/d3fk/mailman2/
 
### Image tag d3fk/mailman2:latest

The **d3fk/mailman2:latest** image available from the Docker Hub is built automatically (automated build on each change of this repo + automated build triggered regularly) so that using the d3fk/mailman2:latest image ensures you to have the latest updated(including security fixes) and functional version available of mailman2, exim4 and apache in a lightweight Debian buster (Debian 10) till the end of the [LTS of this Debian release](https://wiki.debian.org/DebianReleases).
 
### Image tag d3fk/mailman2:stable 
In case you prefer a fixed version of this d3fk/mailman2 container to avoid any possible change in its behaviour, the d3fk/mailman2:stable image is also made available from the Docker hub. This image had a stable behaviour observed in production, so that it was freezed in a release of this repo and built from the Docker hub by automated build. It won't be changed or rebuilt in the future (the code is available from the "releases" section of this repo).

image:tag **d3fk/mailman2:stable**
```sh
$ docker pull d3fk/mailman2:stable
```


## ENVIRONMENT

- `URL_HOST` - the subdomain.domain of the web server on which the mailman web interfaces will be made available:used for the URL
- `EMAIL_HOST` - the email host name: the subdomain and/or domain that will be used by your lists
- `MASTER_PASSWORD` - the master password of the mailing lists - default is set to "example"
- `LIST_ADMIN` - the email address of the lists administrator - used to create the admin account 
- `LIST_LANGUAGE_CODE` - default is set to english with the value: "en"
- `ENABLE_SPF` - if you are not behind a loadbalancer or if you can get the origin IP from your container it might be useful to enable SPF check to avoid identity usurpation. Enabling this option will use about 2.5Mb of additional disk space. This var is waiting for a stringified boolean and the default value is set to "false"
- `URL_ROOT` -  this env allows to add a root dir to mailman so that it is not obvious for bots. Don't forget the trailling slash or let empty if root has to be "URL_HOST/". The default value is set to "lists/"
- `URL_PATTERN` - Possible values are "http" and "https" ... might be usefull to set it to "https" with an ingress and letsencrypt certmanager for example - default value set to "http"


## Basic usage

The following is just an example, you have to define your own environment variables according to your DNS configuration and your requirements: 

```sh
$ docker run --rm -d -p 80:80 -p 25:25 --name mailman -e URL_HOST=lists.example.com -e EMAIL_HOST=mails.example.com  -e LIST_ADMIN=youremail@example.com  d3fk/mailman2
```

Then visit the logs of the mailman container you have created:

```sh
$ docker logs mailman 
```

The logs will display the deployment steps of the container and provide you in the end with a valid DKIM public key value and the DKIM txt record that can be added to your DNS records to enable DKIM check for your mailman mailing list server.

In case you didn't yet configured your DNS for emails and web server, your web server is already reachable from http://localhost (welcome text) and if you let the URL_ROOT at its default value the mailman admin interface can be reached from (http://localhost/lists/admin/)

## DNS configuration
comming soon ...

## Advanced configuration
comming soon ...

## mailman configuration
Most of the mailman configuration can be done from however in case you need to change the default behaviour for the future mailing list creation you can edit the mailan configuration by replacing them with using a simple docker volume.

The default mailman configuration for email sending is set to wrap in order to improve the deliverabelity of the email sent through the mailing lists.


## Using with Kubernetes

In order to allows you a fast set up with kubernetes, you can use as a template the YAML files provided in the k8s directory (deployment, service,,ingress) of this repository

to be continued...
