FROM ubuntu:14.04.1

MAINTAINER Dewey Sasser <dewey@sasser.com>

ADD AutomaticCleanup /etc/apt/apt.conf.d/99AutomaticCleanup

RUN apt-get update

RUN apt-get install -y apache2

RUN apt-get install -y xymon

EXPOSE 80

CMD apachectl -DFOREGROUND
