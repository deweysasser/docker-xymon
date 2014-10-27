FROM ubuntu:14.04.1

MAINTAINER Dewey Sasser <dewey@sasser.com>

ADD AutomaticCleanup /etc/apt/apt.conf.d/99AutomaticCleanup

RUN apt-get update

RUN apt-get install -y apache2

RUN a2enmod rewrite

RUN a2enmod authz_groupfile

RUN apt-get install -y xymon

RUN a2enmod cgi

ADD start /root/start

ADD xymon.conf /etc/apache2/conf-enabled/00-xymon.conf

EXPOSE 80
EXPOSE 1984

CMD sh /root/start
