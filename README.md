# Lightweight useful mailman2 from buster-slim (Angatar> d3fk/mailman2)
A useful compact mailman2 + exim4 container based on debian(10) buster-slim to easily create and manage your mailing lists (including web interfaces).

Debian buster is the latest Debian release that contains the so convenient mailman2. This container intends to provide a stable and easy way to deploy a mailing lists manager with mailman2 and exim4. 

## Get this image (d3fk/mailman2)
The best way to get this d3fk/mailman2 image is to pull the prebuilt image from the Docker Hub Registry.

The image is prebuilt from Docker hub with "automated build" option.

image name **d3fk/mailman2**
```sh
$ docker pull d3fk/mailman2:latest
```
Docker hub repository: https://hub.docker.com/r/d3fk/mailman2/

## Image tag d3fk/mailman2:latest

The **d3fk/mailman2:latest** image available from the Docker Hub is built automatically (automated build on each change of this repo + automated build triggered regularly) so that using the d3fk/mailman2:latest image ensures you to have the latest updated(including security fixes) and functional version available of mailman2 and exim4 in a lightweight Debian buster till the end of the [LTS of this Debian release](https://wiki.debian.org/DebianReleases).
 
## Image tag d3fk/mailman2:stable 
In case you prefer a fixed version of this d3fk/mailman2 container to avoid any possible change in its behaviour, the d3fk/mailman2:stable image is also made available from the Docker hub. This image had a stable behaviour observed in production, so that it was freezed in a release of this repo and built from the Docker hub by automated build. It won't be changed or rebuilt in the future (the code is available from the "releases" section of this repo).

image:tag **d3fk/mailman2:stable**
```sh
$ docker pull d3fk/mailman2:stable
```


## ENVIRONMENT

- `URL_HOST` - the URL subdomain.domain of the web server on which the mailman web interfaces will be made available
- `EMAIL_HOST` - the email host name: the subdomain and/or domain that will be used by your lists
- `MASTER_PASSWORD` - the master password of the mailing lists - default is set to "example"
- `LIST_ADMIN` - the email address of the lists administrator
- `LIST_LANGUAGE_CODE` - default is set to english with the value: "en"
- `ENABLE_SPF` - if you are not behind a loadbalancer or if you can get the origin IP from your container it might be useful to enable SPF to avoid identity usurpation. It is boolean and the default value is set to "false"
- `URL_ROOT` -  this env allows to add a root dir to mailman so that it is not obvious for bots. Don't forget the trailling slash or let empty if root has to be "URL_HOST/".default value set to "lists/"
- `URL_PATTERN` - Possible values are "http" and "https" ... might be usefull to set it to "https" with an ingress and letsencrypt certmanager for example. default value "http"


## Basic usage

Exemple for limited usage of interfaces on your localhost with emailing from @lists.example.com that has to be changed and cofigured according to your DNS configuration 

```sh
$ docker run --rm -d -p 80:80 -p 25:25 --name mailman -e URL_HOST=lists.example.com -e EMAIL_HOST=mails.example.com d3fk/mailman2
```

Then visit the logs of the container:

```sh
$ docker logs mailman 
```


The logs will display the deployment steps and provide you in the end with a valid DKIM public key value to add to your DNS records.




