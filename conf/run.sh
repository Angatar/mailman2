#!/bin/bash
# By d3fk::Angatar

if [ ! -f started ]; then

        #set default email originator /  and root user aliase
        echo "root: ${LIST_ADMIN}" > /etc/email-addresses
        /bin/sed -i "s/admin@example\.com/${LIST_ADMIN}/" /etc/aliases

        #declare Hostname in hostname and mailname files
        echo "${EMAIL_HOST}" > /etc/hostname
        echo ${EMAIL_HOST} > /etc/mailname

        hostname -I |  awk -v hostname=${EMAIL_HOST} '{disp=$1"    " hostname; print disp}' >> /etc/hosts

        #Change owner:group of mailman directory
        chown -R list:list /var/lib/mailman/

        #Create docroot
        mkdir /var/www/lists
        echo "<html><h2>Welcome to ${URL_HOST}</h2></html>" > /var/www/lists/index.html

        mailmancfg='/etc/mailman/mm_cfg.py'

        # define the URL pattern for mailman
        if [ $URL_PATTERN != "http" ]; then
        echo "DEFAULT_URL_PATTERN = 'https://%s/${URL_ROOT}'" >> $mailmancfg
        else
        echo "DEFAULT_URL_PATTERN = 'http://%s/${URL_ROOT}'" >> $mailmancfg
        fi

        # enable spf check if requested
        if [ $ENABLE_SPF_CHECK = "true" ]; then
        echo "installing SPF tools before enabling..."
        apt-get install -y spf-tools-perl

        /bin/sed -i "s/#CHECK_RCPT_SPF/CHECK_RCPT_SPF/" /etc/exim4/conf.d/main/00_local_macros
        echo "SPF CHECK is now enabled"
        fi

        # Replace default hostnames with runtime values:
        /bin/sed -i "s/lists\.example\.com/${EMAIL_HOST}/" /etc/exim4/conf.d/main/00_local_macros
        /bin/sed -i "s/lists\.example\.com/${EMAIL_HOST}/" /etc/exim4/conf.d/main/04_mailman_options
        /bin/sed -i "s/lists\.example\.com/${EMAIL_HOST}/" /etc/exim4/update-exim4.conf.conf
        /bin/sed -i "s/lists\.example\.com/${URL_HOST}/" /etc/apache2/apache2.conf
        /bin/sed -i "s/lists\.example\.com/${URL_HOST}/" /etc/apache2/sites-available/mailman.conf
        /bin/sed -i "s/URL_ROOT\//${URL_ROOT//\//\\/}/" /etc/apache2/sites-available/mailman.conf
        /bin/sed -i "s/lists\.example\.com/${EMAIL_HOST}/" $mailmancfg
        /bin/sed -i "s/DEFAULT_URL_HOST.*\=.*/DEFAULT_URL_HOST\ \=\ \'${URL_HOST}\'/" $mailmancfg
        /bin/sed -i "s/DEFAULT_SERVER_LANGUAGE.*\=.*/DEFAULT_SERVER_LANGUAGE\ \=\ \'${LIST_LANGUAGE_CODE}\'/" $mailmancfg


        echo -n "Setting up Mailman..."
        {
                dpkg-reconfigure mailman

        #      especialy for debian:buster
        mkdir /var/run/mailman
        chown list:list /var/run/mailman/
        ln -s /var/lib/mailman/bin/mailmanctl /etc/init.d/mailman
        }


        echo -n "Initializing mailing lists..."
        {
                /usr/sbin/mmsitepass ${MASTER_PASSWORD}
                /usr/sbin/newlist -q -l ${LIST_LANGUAGE_CODE} mailman ${LIST_ADMIN} ${MASTER_PASSWORD}
        }

        #update aliases
        /usr/bin/newaliases


        echo -n "Setting up Apache web server..."
        {
                a2enmod -q cgi
                if [ $SSL_FROM_CONTAINER = "true" ]; then
                if [ $SSL_SELFSIGNED = "true" ]; then
                        make-ssl-cert generate-default-snakeoil --force-overwrite
                        echo -n "self signed SSL certificate freshly regenerated..."
                fi
                a2enmod ssl
                fi
                a2dissite -q 000-default
                a2ensite mailman.conf
        # edit apache default security.conf for production
                /bin/sed -i "s/ServerSignature On/ServerSignature Off/" /etc/apache2/conf-available/security.conf
                /bin/sed -i "s/ServerTokens OS/ServerTokens Prod/" /etc/apache2/conf-available/security.conf
                echo "Apache2 new configuration is now activated"
                echo "The service apache2 will be started at the end of this container deployment"
        }

        echo "Setting up RSA keys for DKIM..."
        {
                if [ ! -f /etc/exim4/tls.d/private.pem ]; then
                        mkdir -p /etc/exim4/tls.d
                        openssl genrsa -out /etc/exim4/tls.d/private.pem 2048
                        openssl rsa -in /etc/exim4/tls.d/private.pem -out /etc/exim4/tls.d/public.pem -pubout
                fi
        }

        key=$(sed -e '/^-/d' /etc/exim4/tls.d/public.pem|paste -sd '' -)

        echo "setting up cert for TLS..."
        {
                if [ ! -f /etc/exim4/exim.key ]; then
                        openssl req -x509 -sha256 -days 9000 -nodes -newkey rsa:4096 -keyout /etc/exim4/exim.key -out /etc/exim4/exim.crt -subj "/O=${EMAIL_HOST}/OU=IT Department/CN=${EMAIL_HOST}"
                        echo "Cert for TLS now generated..."
                fi
        }

        echo "Fixing exim4 permissions..."
        {
                chown -R Debian-exim:Debian-exim /etc/exim4
                chown -R Debian-exim /var/log/exim4
        }

        #build updated exim config file
        echo  "Setting up Exim4..."
        {
                update-exim4.conf
        }

        echo  "Fixing mailman permissons..."
        {
                /usr/lib/mailman/bin/check_perms -f > /dev/null
        }

        touch started
        echo "///////////This d3fk/mailman2 container is now configured !///////////"

fi

echo "Starting up services..."
{
	/etc/init.d/exim4 start
	/etc/init.d/mailman start
echo " exim4 OK ... mailman OK ..."
}

echo '------------- Apache2 service is starting -------------'
echo
echo
cat << EOB

    ***********************************************
    *                                             *
    *   TO COMPLETE DKIM SETUP, COPY THE          *
    *   FOLLOWING CODE INTO A NEW TXT RECORD      *
    *   IN YOUR DNS SERVER:                       *
    *                                             *
    ***********************************************

EOB
echo "listsdkim._domainkey.${EMAIL_HOST} IN TXT \"v=DKIM1; k=rsa; p=$key\""
echo
echo

# defining stop actions in case of SIGTERM or SIGINT
graceful_stop() {
  echo "The container was asked to terminate its processes gracefully..."
  /etc/init.d/mailman stop
  /etc/init.d/exim4 stop
  apachectl -k stop
  echo "Apache2 server is now stopped."
  echo "Asking for exit with code 143 (SIGTERM)..."
  exit 143
}

# trapping SIGTERM and SIGINT termination signals and trigger actions
trap 'graceful_stop' SIGTERM SIGINT

echo '------------- CONTAINER UP AND RUNNING! -------------'
# Starting apache2 in foreground & wait
apachectl -DFOREGROUND -k start & wait ${!}

