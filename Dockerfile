FROM ubuntu:groovy-20210614
MAINTAINER Dewey Sasser <dewey@deweysasser.com>

ENV DEBIAN_FRONTEND=noninteractive TZ=posixrules
ADD AutomaticCleanup /etc/apt/apt.conf.d/99AutomaticCleanup

# Install what we need from Ubuntu
RUN apt-get update

# tcpdump is for debugging client issues, others are required
RUN apt-get install -y curl xymon apache2 tcpdump ssmtp mailutils rrdtool ntpdate

# Get the 'dumb init' package for proper 'init' behavior
RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_amd64.deb > dumb-init.deb && \
    dpkg -i dumb-init.deb && \
    rm dumb-init.deb

ADD add-files /

# Enable necessary apache components
# make sure the "localhost" is correctly identified
# and ensure the ghost list can be updated
# Then, save the configuration so when this container starts with a
# blank volume, we can initialize it

RUN a2enmod rewrite authz_groupfile cgi; \
     perl -i -p -e "s/^127.0.0.1.*/127.0.0.1    xymon-docker # bbd http:\/\/localhost\//" /etc/xymon/hosts.cfg; \
     chown xymon:xymon /etc/xymon/ghostlist.cfg /var/lib/xymon/www ; \
     tar -C /etc/xymon -czf /root/xymon-config.tgz . ; \
     tar -C /var/lib/xymon -czf /root/xymon-data.tgz .



VOLUME /etc/xymon /var/lib/xymon
EXPOSE 80 1984

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/etc/init.d/container-start"]
