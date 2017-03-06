# functions and variables for GIT

# The current branch
GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

# How to look up the origin of a branch
define GIT_ORIGIN
$(shell (git rev-parse --abbrev-ref --symbolic-full-name $1@{push} | awk -F/ '{print $$1}'))
endef


info::
	@echo GIT_BRANCH=${GIT_BRANCH}