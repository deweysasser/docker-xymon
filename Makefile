# template for Makefile that handles releases via GIT

all::

# Local variable overrides
-include local.mk

# Use semantic versioning template
include semver.mk

# and GIT release tools
include release.mk

# a number of projects that track external state, including docker, aws stuff, ...
include external-state.mk

# AWS docker magic
include docker.mk
include aws-ecr.mk
