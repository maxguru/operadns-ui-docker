FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive

# fix to make postgresql-client install without errors
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7

RUN apt-get update -y \
&& apt-get upgrade -yq --no-install-recommends --no-install-suggests \
&& apt-get install -yq --no-install-recommends --no-install-suggests msmtp-mta apache2-utils libldap2-dev libicu-dev libpq-dev postgresql-client netcat-openbsd \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install pdo_pgsql pgsql ldap intl

RUN cd /var/www \
&& rm -rf html \
&& curl -L -o dns-ui.tar.gz https://github.com/operasoftware/dns-ui/archive/5309acd70e4ad2f023ca4725110a25a5e8342afe.tar.gz \
&& tar --strip-components=1 -zxvf dns-ui.tar.gz \
&& rm dns-ui.tar.gz \
&& ln -s public_html html \
&& chown -R www-data:www-data .

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY config.ini /var/www/config/config.ini.orig
COPY entrypoint.sh /

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

VOLUME /data
