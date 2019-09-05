#!/usr/bin/env bash
set -e

rm -f /application/tmp/pids/server.pid

cp /application/config/apache2/beehive* /etc/apache2/sites-available/
cp /application/config/apache2/ports.conf /etc/apache2/ports.conf
cp /application/config/apache2/apache2.conf /etc/apache2/apache2.conf
cp /application/config/apache2/*.pem /etc/apache2/
cp /application/config/shibboleth/* /etc/shibboleth/

a2enmod ssl
a2enmod passenger
# a2enmod rewrite
a2dissite 000-default
a2ensite beehive
a2ensite beehive-ssl

/etc/init.d/shibd restart -f -c /etc/shibboleth/shibboleth2.xml -p /var/run/shibboleth/shibd.pid

/usr/sbin/apache2ctl -DFOREGROUND
