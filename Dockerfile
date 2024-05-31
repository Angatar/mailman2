FROM debian:buster-slim
LABEL org.opencontainers.image.authors="d3fk::Angatar"
LABEL org.opencontainers.image.source="https://github.com/Angatar/mailman2.git"
LABEL org.opencontainers.image.url="https://github.com/Angatar/mailman2"

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

ENV URL_HOST lists.example.com
ENV EMAIL_HOST lists.example.com
ENV MASTER_PASSWORD example
ENV LIST_ADMIN admin@lists.example.com
ENV LIST_LANGUAGE_CODE en
ENV ENABLE_SPF_CHECK "false"
ENV URL_ROOT lists/
ENV URL_PATTERN http
ENV SSL_FROM_CONTAINER "false"
ENV SSL_SELFSIGNED "false"

COPY conf/run.sh /

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y mailman exim4 apache2 apache2-data apache2-utils curl \
    && apt-get remove -y --purge --autoremove mariadb-common mysql-common bzip2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "ServerName $URL_HOST" >> /etc/apache2/apache2.conf \
    && echo "tls_require_ciphers = NORMAL:-VERS-SSL3.0:-VERS-TLS1.0:-VERS-TLS1.1" > /etc/exim4/conf.d/main/00_exim4-config_tlsversions \
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
VOLUME /var/spool
VOLUME /var/lib/mailman/archives
VOLUME /var/lib/mailman/lists
VOLUME /etc/exim4/tls.d

EXPOSE 25 465 587 80 443

CMD ["/run.sh"]

HEALTHCHECK CMD curl -f localhost || exit 1
