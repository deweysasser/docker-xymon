# Base URL of Amazon docker regstries
REGISTRY_BASE?=
PROFILE=default
PUSH=$(if $(REGISTRY_BASE),true,false)
ECR=aws --profile $(PROFILE) --output text ecr

# In the future, we might want to run production off of a "release" branch
ifeq (${GIT_BRANCH},release)
PUSH_TAG=stable
else
PUSH_TAG=${TAG}
endif

PUSHED=$(subst .built,.pushed,$(IMAGES))

ifeq ($(PUSH),true)
all:: $(STATE)/ecr-login $(PUSHED) 
endif

$(STATE)/%.pushed: $(STATE)/%.repo $(STATE)/%.built  | $(STATE)/ecr-login
	docker tag $*:$(TAG) $(REGISTRY_BASE)/$*:$(PUSH_TAG)
	docker push $(REGISTRY_BASE)/$*:$(PUSH_TAG)
	touch $@


$(STATE)/%.repo: | $(STATE)
	$(ECR) describe-repositories --query 'repositories[*].repositoryName' --repository-names $* 2>/dev/null || $(ECR) create-repository --repository-name $*


cleanup: $(foreach p,$(PUSHED),cleanup/$(notdir $p))

cleanup/%.pushed:
	for i in $$($(ECR) describe-images --repository-name $* --query imageDetails[*].[imageDigest,imageTags[0]] | awk '/None/{print $$1}' | head -n -2); do $(ECR) batch-delete-image --repository-name $* --image-ids imageDigest=$$i; done


info::
	@echo PUSH=$(PUSH)
	@echo PUSHED=$(PUSHED)


ROUNDED=$(shell echo $$(( $$(date +%s) / (3600*6) * 3600*6 )))

$(STATE)/ecr-login: $(STATE) $(STATE)/ecr-login.$(PROFILE).$(ROUNDED)
	aws --profile $(PROFILE) ecr get-login | tr -d '\r' > $@
	bash $@

$(STATE)/ecr-login.%:
	rm -f $(STATE)/ecr-login.*
	touch $@

