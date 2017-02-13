# Might want to add "--no-cache" to this
DBUILD_FLAGS=
DBUILD=docker build $(DBUILD_FLAGS)
PROJECT?=$(notdir $(CURDIR))

DOCKERFILE=$(wildcard Dockerfile)

# In the future, we might want to run production off of a "release" branch
TAG=latest

IMAGES=$(foreach x,$(wildcard */Dockerfile),$(patsubst %/,%,$(dir $(STATE)/$x)).built) $(if $(DOCKERFILE),$(STATE)/$(PROJECT).built)

all:: $(IMAGES)

$(STATE)/%.built: %/*
	$(DBUILD) -t $*:$(TAG) $*
	touch $@

ifdef DOCKERFILE
$(STATE)/$(notdir $(CURDIR)).built: Dockerfile 
	$(DBUILD) -t $(PROJECT):$(TAG) .
	touch $@
endif


info::
	@echo IMAGES=$(IMAGES)
	@echo DOCKERFILE=$(DOCKERFILE)
	@echo PROJECT=$(PROJECT)


