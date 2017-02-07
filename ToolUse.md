Making a Release
================

The file 'release.mk' includes functions for making a release using
some standardized GIT conventions:

* release happens from a 'release' branch
* each release merges from the current branch
* each release increments a version number (http://semver.org) and
  includes release notes

As long as your Makefile includes 'release.mk', you can use "make
(major|minor|patch)-release" to make a standardized release.