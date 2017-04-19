FROM php:5.6-apache
MAINTAINER Derek Vance <dvance@cerb-tech.com>

RUN apt-get update && \
    apt-get -y install git
	
RUN git clone https://github.com/operasoftware/dns-ui.git

RUN sed -i 's_DocumentRoot /var/www/html_DocumentRoot /var/www/html/dns-ui/public\_html/_' /etc/apache2/sites-available/000-default.conf
RUN sed -i '/^DocumentRoot/a DocumentIndex init.php' /etc/apache2/sites-available/000-default.conf
