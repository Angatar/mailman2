FROM debian:buster-slim
MAINTAINER d3fk 

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

ENV URL_HOST lists.example.com
ENV EMAIL_HOST lists.example.com
ENV MASTER_PASSWORD example
ENV LIST_ADMIN admin@lists.example.com
ENV LIST_LANGUAGE_CODE en
# if you are not behind a loadbalancer or if you can get the origin IP it might be useful to enable SPF to avoid identity usurpation
ENV ENABLE_SPF FALSE
# Add a root dir to mailman so that it is not obvious for bots, don't forget the trailling slash or let empty if root has to be "/"
ENV URL_ROOT lists/
# Possible values for URL_PATTERN are http and https 
#... might be usefull with an ingress and letsencrypt certmanager for example
ENV URL_PATTERN http 

COPY conf/run.sh /

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y mailman exim4 apache2 \
    && apt-get clean \
    && chmod +x /run.sh

COPY conf/00_local_macros /etc/exim4/conf.d/main/
COPY conf/04_mailman_options /etc/exim4/conf.d/main/
COPY conf/450_mailman_aliases /etc/exim4/conf.d/router/
COPY conf/40_mailman_pipe /etc/exim4/conf.d/transport/
COPY conf/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf

COPY conf/mm_cfg.py /etc/mailman/mm_cfg.py

COPY conf/mailman.conf /etc/apache2/sites-available/

COPY conf/aliases /etc/aliases

VOLUME /var/log/mailman
VOLUME /var/log/exim4
VOLUME /var/log/apache2
VOLUME /var/lib/mailman/archives
VOLUME /var/lib/mailman/lists
VOLUME /etc/exim4/tls.d

EXPOSE 25 80

CMD ["/run.sh"]
