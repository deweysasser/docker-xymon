FROM ubuntu:14.04.1
MAINTAINER Dewey Sasser <dewey@sasser.com>

env DEBIAN_FRONTEND=noninteractive
ADD AutomaticCleanup /etc/apt/apt.conf.d/99AutomaticCleanup

# Install what we need from Ubuntu
RUN apt-get update
RUN apt-get install -y curl xymon apache2

# Get the 'dumb init' package for proper 'init' behavior
RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb > dumb-init.deb && \
    dpkg -i dumb-init.deb && \
    rm dumb-init.deb

RUN a2enmod rewrite authz_groupfile cgi

# make sure the "localhost" is correctly identified
RUN perl -i -p -e "s/^127.0.0.1.*/127.0.0.1    xymon-docker # bbd http:\/\/localhost\//" /etc/xymon/hosts.cfg

# And save the configuration so when this container starts with a blank volume, we can initialize it
RUN tar -C /etc/xymon -czf /root/xymon-config.tgz .; tar -C /var/lib/xymon -czf /root/xymon-data.tgz .

ADD start /root/start

ADD placeholder.html /var/lib/xymon/www/index.html
ADD redirect.html    /var/www/html/index.html

ADD xymon.conf /etc/apache2/conf-enabled/00-xymon.conf

VOLUME /etc/xymon
VOLUME /var/lib/xymon

EXPOSE 80
EXPOSE 1984

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sh", "/root/start"]
