######################################################################
# Create AWS stacks and tasks
######################################################################

# the project we're working in
PROJECT=$(notdir $(CURDIR))

# A prefix applied to all resources so different users/contexts do not
# step on each other
PREFIX?=$(PROJECT)-$(USER)-sandbox

# The AWS profile to use 
PROFILE?=sandbox

# AWS command
AWS=aws --profile $(PROFILE)

# Where to store runtime state
CFSTATE=$(STATE)/$(PROFILE)
$(STATE):: $(CFSTATE)

# Default targets
all:: $(foreach s,$(wildcard *.cf),$(CFSTATE)/$(PREFIX)-$(notdir $s))


# The standard set of parameters we supply to every cloudformation template
STANDARD_PARAMETERS=ParameterKey=Prefix,ParameterValue=$(PREFIX) ParameterKey=CreatedBy,ParameterValue=$(USER) 

# How to turn a .params files into a command line set of
# cloudformation parameters

define PARAMETERS
$(shell perl -n -e 'chop; chop if /\r$$/; next if /^#/; print "\"ParameterKey=$$1,ParameterValue=$$3\" \n "if /(.*)(\s*=\s*)(.*)[\s\\r]*?/; ' $1)
endef

######################################################################
# How to build stacks
######################################################################

$(CFSTATE)/$(PREFIX)-%.cf: $(CFSTATE)

$(CFSTATE)/$(PREFIX)-%.cf: %.cf %.params $(CFSTATE)
	@if [ -f $@ ] ; then \
	echo "Updating Stack $(notdir $@)" ;\
	$(AWS) cloudformation  update-stack --capabilities CAPABILITY_IAM  --stack-name $(PREFIX)-$* --template-body file://$<  --parameters $(STANDARD_PARAMETERS) $(call PARAMETERS,$*.params); \
	else  \
	echo "Creating Stack $(notdir $@)" ;\
	$(AWS) cloudformation  create-stack --capabilities CAPABILITY_IAM  --stack-name $(PREFIX)-$* --template-body file://$<  --parameters $(STANDARD_PARAMETERS) $(call PARAMETERS,$*.params); \
	fi
	@touch $@

%.params:
	touch $@

######################################################################
# How to destroy stacks
######################################################################

delete/%.cf: $(CFSTATE) 
	test -f $(CFSTATE)/$(PREFIX)-$* && $(AWS) cloudformation delete-stack --stack-name $(PREFIX)-$(basename $*) || true
	rm $(CFSTATE)/$(PREFIX)-$*

# Destroy is a speical case -- it's a very dangerous operation, so only allow it if we explitictly confirm
ifeq ($(CONFIRM),yes)
destroy: $(foreach s,$(wildcard *.cf),delete/$s.cf)
else
destroy:
	@echo "WARNING:  'make destroy' is dangerous."
	@echo "It will delete all stack resources *INCLUDING* buckets and file systems with data"
	@printf "\nDestroy would delete the following stacks: $(foreach s,$(wildcard *.cf),\n   - $(PREFIX)-$(subst .cf,,$s))\n\n"
	@echo "You must run it with:"
	@echo "  make $(MAKEFLAGS) destroy CONFIRM=yes"
endif

######################################################################
# Templates for various types
######################################################################

templates: templates/stack.template
templates/stack.template:
	mkdir -p $(dir $@)
	$(AWS) cloudformation create-stack --generate-cli-skeleton > $@

######################################################################
# Generate the state capture directory and pre-populate it
######################################################################

$(CFSTATE)::  $(CFSTATE)/.cloudformation-inspect

$(CFSTATE)/.cloudformation-inspect:
	@mkdir -p $(dir $@)
	@echo "Locating existing stacks"
	@for stack in $$($(AWS) --output text cloudformation describe-stacks --query "Stacks[*].StackName" | tr -d '\r'); do echo  "  - " $$stack; touch $(dir $@)/$$stack.cf; done
	@touch $@


# Print general info
info::
	@echo PROJECT = $(PROJECT)


test:
	echo $(call PARAMETERS,ecs-cluster.params)