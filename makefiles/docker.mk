# Might want to add "--no-cache" to this
DBUILD_FLAGS=
DBUILD=docker build $(DBUILD_FLAGS)
IMAGE_PREFIX?=$(USER)-sandbox-
DOCKERFILE=$(wildcard Dockerfile)

# In the future, we might want to run production off of a "release" branch
TAG=latest

IMAGES=$(foreach x,$(wildcard */Dockerfile),$(STATE)/$(IMAGE_PREFIX)$(patsubst %/,%,$(dir $x)).built) $(if $(DOCKERFILE),$(STATE)/$(IMAGE_PREFIX)$(notdir $(CURDIR)).built)

all:: $(IMAGES)

$(STATE)/$(IMAGE_PREFIX)%.built: %/*
	$(DBUILD) -t $(IMAGE_PREFIX)$(patsubst %/,%,$(dir $<)):$(TAG) $*
	@mkdir -p $(dir $@); touch $@

ifdef DOCKERFILE
$(STATE)/$(IMAGE_PREFIX)$(notdir $(CURDIR)).built: Dockerfile 
	$(DBUILD) -t $(notdir $(basename $@)):$(TAG) .
	@mkdir -p $(dir $@); touch $@
endif


info::
	@echo IMAGES=$(IMAGES)
	@echo DOCKERFILE=$(DOCKERFILE)


