docker-xymon
============

Dockerization of the Xymon monitoring system on an Ubuntu base

Quick Start
===========

    docker run -d -p 80:80 -p 1984:1984 -v /etc/xymon:/etc/xymon -v /var/lib/xymon:/var/lib/xymon --name xymon deweysasser/xymon

or use docker-compose with

```
xymon:
  image: deweysasser/xymon
  ports:
    - 80:80
    - 1984:1984
  volumes:
    - xymon-config:/etc/xymon
    - xymon-data:/var/lib/xymon
  environment:
    SSMTP_mailhub: mail.example.com
    SSMTP_AuthUser: user
    SSMTP_AuthPass: password
    SSMTP_AuthMethod: LOGIN
    SSMTP_UseTLS: "Yes"
```

Interface
=========

Ports
-----

* 80 -- Web server
* 1984 -- Xymon/bb client reporting port

You only need to expose port 1984 if you are going to use a xymon
client
(e.g. [native](http://packages.ubuntu.com/trusty/net/xymon-client),
[Windows](http://bbwin.sourceforge.net/) or
[docker](https://hub.docker.com/r/deweysasser/xymon-client/)).

Port 1984 should *NOT* be exposed to public (Internet facing) traffic.

Sending Mail
------------

Any environment variables with the prefix `SSMTP_` have the prefix
stripped and are otherwise copied verbatim into
[`/etc/ssmtp/ssmtp.conf`](https://linux.die.net/man/5/ssmtp.conf).

You will need at least the environment variable `SSMTP_mailhub` and
will likely want:

* `SSMTP_mailhub`
* `SSMTP_AuthUser`
* `SSMTP_AuthPass`
* `SSMTP_AuthMethod=LOGIN`
* `SSMTP_UseTLS=Yes`
* `SSMTP_STARTTLS=Yes`

You can also choose to configure the file in other ways, for example
in a volume or by extending this docker image.

You may then configure [Xymon
alerts](http://xymon.sourceforge.net/xymon/help/xymon-alerts.html) as
usual.

See the documentation for
[SSMTP](https://linux.die.net/man/5/ssmtp.conf) and [Xymon
alerts](http://xymon.sourceforge.net/xymon/help/xymon-alerts.html) for
more details.

Volumes
-------

* /etc/xymon -- all xymon configuration data
* /var/lib/xymon -- xymon data (monitoring state)

Timezone
--------

By default the container will use the `posixrules` TZ rule set. If
you'd like to override this, set the environment variable 'TZ',
e.g. `docker run -d -e TZ=America/New_York`


Known Issues
============

* Password protection on cgi directories is currently disabled

Maintainer
==========

Please submit all issues/suggestions/bugs via
https://github.com/deweysasser/docker-xymon
