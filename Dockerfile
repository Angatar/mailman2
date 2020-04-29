FROM debian:buster-slim
MAINTAINER d3fk 

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

ENV URL_HOST lists.example.com
ENV EMAIL_HOST lists.example.com
ENV MASTER_PASSWORD example
ENV LIST_ADMIN admin@lists.example.com
ENV LIST_LANGUAGE_CODE en
ENV ENABLE_SPF "false"
ENV URL_ROOT lists/
ENV URL_PATTERN http 
ENV SSL_FROM_CONTAINER "false"
ENV SSL_AUTOSIGNED "false"

COPY conf/run.sh /

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y mailman exim4 apache2 \
    && apt-get clean \
    && echo "ServerName $URL_HOST" >> /etc/apache2/apache2.conf \
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

EXPOSE 25 465 587 80 443

CMD ["/run.sh"]
