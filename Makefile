# Top level makefile templates -- customize at will

# The default target -- other makefiles will add dependencies
all::

# Local variable overrides
-include local.mk

# Some standard make targets
include makefiles/standard.mk

# Use semantic versioning template
include makefiles/semver.mk

# and GIT release tools
include makefiles/git-release.mk

# a number of projects that track external state, including docker, aws stuff, ...
include makefiles/external-state.mk

# AWS docker magic
include makefiles/docker.mk
include makefiles/aws-ecr.mk
