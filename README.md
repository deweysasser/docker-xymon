docker-xymon
============

Dockerization of the Xymon monitoring system on an Ubuntu base

Example
=======

    docker build -t xymon docker-xymon
    docker run -d -p 80:80 -p 1984:1984 -v /etc/xymon:/etc/xymon --name xymon xymon

Interface
=========

Ports
-----

* 80 -- Web server
* 1984 -- Xymon/bb client reporting port

Volumes
-------

* /etc/xymon -- all xymon configuration data
* /var/lib/xymon -- xymon data (monitoring state)

Timezone
--------

By default the container will use the 'posixrules' TZ rule set. If
you'd like to override this, set the environment variable 'TZ',
e.g. `docker run -d -e TZ=America/New_York`


Known Issues
============

* Password protection on cgi directories is currently disabled
* There is no way for Xymon to send email

Maintainer
==========

Please submit all issues/suggestions/bugs via
https://github.com/deweysasser/docker-xymon
