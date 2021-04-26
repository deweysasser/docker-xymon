Release 1.5
============

* Add ntpdate to installed packages.

* Update author email

* Update to 20.04 and dumb-init 1.2.5.


Release 1.4
============

* Upgrade to latest versions

- Ubuntu 18.04

- Xymon 4.3.28

- Yelp/dumb-init 1.2.2

* add install rrdtool


Release 1.3
============

* Include mailutils installation for testing email

* Enhanced documentation

* Configure SSMTP for mail sending

This addresses issue #1 and allows Xymon to send mail through an
external mail server, with auth (mostly by passing all mail configuration
problems to the user via ssmtp configuration).

* Reduce layers in image

Move all files to be added to the 'add-files' directory and add them all
with a single docker command.

We still add the AutomaticCleanup and dumb-init files separately, but this
substantially reduces layering.


Release 1.2
============

* Dynamically generate a ghost list page for ghost hosts

* Remove outdated apache PID file


Release 1.1
============

* Set default timezone and make provisions for runtime timezone setting

* use dumb-init for proper process cleanup/signal handling

* Reduce layers in docker image

