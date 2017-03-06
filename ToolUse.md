Library of make recipes
=======================

This project contains a library of includable makefiles that define
recipes for building/manipulating various things, including docker,
aws, ECR, ECS, ...

Currently includes

* release.mk -- implements a protocol for managing a release branch in
  your git project, including tagging and release notes

* semver.mk -- implement semantic versioning extensions for releases.

* docker.mk -- build docker images, either in the base project or in
  subdirectories

* aws-ecr.mk -- push built docker images to AWS ECR


Base Repo
=========

Preconfigured git ignores and attributes.

Additional funcitonality in https://github.com/deweysasser/makelib
