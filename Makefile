# Top level makefile templates -- customize at will

# The default target -- other makefiles will add dependencies
all::

# Local variable overrides
-include local.mk

# Some standard make targets
include standard.mk

# Use semantic versioning template
include semver.mk

# and GIT release tools
include git-release.mk

# a number of projects that track external state, including docker, aws stuff, ...
include external-state.mk

# AWS docker magic
include docker.mk
include aws-ecr.mk
