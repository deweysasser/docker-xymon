FROM ubuntu:14.04.1

MAINTAINER Dewey Sasser <dewey@sasser.com>

ADD AutomaticCleanup /etc/apt/apt.conf.d/99AutomaticCleanup

RUN apt-get update &&  apt-get install -y xymon apache2

RUN a2enmod rewrite authz_groupfile cgi

RUN perl -i -p -e "s/^127.0.0.1.*/127.0.0.1    xymon-docker # bbd http:\/\/localhost\//" /etc/xymon/hosts.cfg

RUN tar -C /etc/xymon -czf /root/xymon-config.tgz .; tar -C /var/lib/xymon -czf /root/xymon-data.tgz .

ADD start /root/start

ADD placeholder.html /var/lib/xymon/www/index.html

ADD redirect.html /var/www/html/index.html

ADD xymon.conf /etc/apache2/conf-enabled/00-xymon.conf

VOLUME /etc/xymon

VOLUME /var/lib/xymon

EXPOSE 80
EXPOSE 1984

CMD sh /root/start
