FROM php:5.6-apache

ENV DEBIAN_FRONTEND=noninteractive

# fix to make postgresql-client install without errors
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7

RUN apt-get update -y \
&& apt-get upgrade -yq --no-install-recommends --no-install-suggests \
&& apt-get install -yq --no-install-recommends --no-install-suggests ssmtp libldb-dev libldap2-dev libcurl4-openssl-dev libicu-dev libpq-dev postgresql-client netcat \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
&& ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

RUN docker-php-ext-install pdo pdo_pgsql pgsql json ldap curl mbstring intl

RUN cd /var/www \
&& rm -rf html \
&& curl -L -o dns-ui.tar.gz https://github.com/operasoftware/dns-ui/archive/master.tar.gz \
&& tar --strip-components=1 -zxvf dns-ui.tar.gz \
&& rm dns-ui.tar.gz \
&& ln -s public_html html \
&& chown -R www-data:www-data .

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY config.ini /var/www/config/config.ini.orig
COPY entrypoint.sh /

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

VOLUME /data
