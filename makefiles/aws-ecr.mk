# Base URL of Amazon docker regstries
PROFILE?=sandbox
PUSH=$(if $(REGISTRY_BASE),true,false)
ECR=aws --profile $(PROFILE) --output text ecr

ifndef REGISTRY_BASE
include ecr-registry.mk
endif

DOCKERFILE=$(wildcard Dockerfile)

PUSHED=$(subst .built,.pushed,$(IMAGES))

ifeq ($(PUSH),true)
all:: $(STATE)/ecr-login $(PUSHED) 
endif

$(STATE)/%.pushed: $(STATE)/%.repo $(STATE)/%.built  | $(STATE)/ecr-login
	docker tag $*:$(TAG) $(REGISTRY_BASE)/$*:$(TAG)
	docker push $(REGISTRY_BASE)/$*:$(TAG)
	touch $@


$(STATE)/%.repo: | $(STATE)
	$(ECR) describe-repositories --query 'repositories[*].repositoryName' --repository-names $* 2>/dev/null || $(ECR) create-repository --repository-name $*


cleanup:: $(foreach p,$(PUSHED),cleanup/$(notdir $p))

cleanup/%.pushed:
	@echo "Cleaning docker image $*"
	@for i in $$($(ECR) describe-images --repository-name $* --query imageDetails[*].[imageDigest,imageTags[0]] | awk '/None/{print $$1}' | head -n -2); do $(ECR) batch-delete-image --repository-name $* --image-ids imageDigest=$$i; done


info::
	@echo PUSH=$(PUSH)
	@echo PUSHED=$(PUSHED)
	@echo REGISTRY_BASE=$(REGISTRY_BASE)


ROUNDED=$(shell echo $$(( $$(date +%s) / (3600*6) * 3600*6 )))

$(STATE)/ecr-login: $(STATE) $(STATE)/ecr-login.$(PROFILE).$(ROUNDED)
	aws --profile $(PROFILE) ecr get-login | tr -d '\r' > $@
	bash $@

$(STATE)/ecr-login.%:
	rm -f $(STATE)/ecr-login.*
	touch $@

ecr-registry.mk:
	echo REGISTRY_BASE=$(patsubst %/,%,$(dir $(shell $(ECR) describe-repositories --repository-names inspect --query 'repositories[0].repositoryUri'  2>/dev/null || $(ECR) create-repository --repository-name inspect --query "repositories[0].repositoryUri"))) > $@
