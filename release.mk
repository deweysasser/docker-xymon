######################################################################
#
#              MAKE procedures for creating a release
#
######################################################################
#
# USAGE:  make major-release|minor-release|patch-release
#
#   This will 
#     * checkout a 'release' branch
#     * merge the current branch to the release
#     * increment the version number as specified 
#     * generate release notes and commit them
#     * create an apporpriate tag
#     * have everything ready to push with 'make release-push'
#
######################################################################


# Various settings -- customize to your environment
RELEASE_BRANCH?=release
RELEASE_NOTES=ReleaseNotes.md

# The current branch
GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

# How to look up the origin of a branch
define GIT_ORIGIN
$(shell (git rev-parse --abbrev-ref --symbolic-full-name $1@{push} | awk -F/ '{print $$1}'))
endef


# Store all version numbers in an external file
include version.mk

ifeq ($(VPATCH), 0)
VERSION=$(VMAJOR).$(VMINOR)
else
VERSION=$(VMAJOR).$(VMINOR).$(VPATCH)
endif


TAG_PREFIX=$(GIT_BRANCH)/

VERSION_STRING=$(VERSION)


release:
	@echo "Use one of:  make major-release, make minor-release, make patch-release"
	@exit 1

patch-bump: version.mk
	perl -i -p -e 's/^VPATCH=(.*)/"VPATCH=" . ($$1 + 1)/e' version.mk
	git add version.mk

minor-bump: version.mk
	perl -i -p \
	-e 's/^VMINOR=(.*)/"VMINOR=" . ($$1 + 1)/e;' \
	-e 's/^VPATCH=(.*)/VPATCH=0/' \
		version.mk
	git add version.mk

major-bump: version.mk
	perl -i -p \
	-e 's/^VMAJOR=(.*)/"VMAJOR=" . ($$1 + 1)/e;' \
	-e 's/^VMINOR=(.*)/VMINOR=0/;' \
	-e 's/^VPATCH=(.*)/VPATCH=0/;' \
		version.mk
	git add version.mk

version-reset version.mk:
	printf "VMAJOR=0\\nVMINOR=0\\nVPATCH=0\n" > version.mk

major-release minor-release patch-release: .release .release/checkout .release/merge 
	make $(subst -release,-bump,$@)
	make $(RELEASE_NOTES) .release/tag .release/master-checkout
	rm -rf .release
	echo "Release merged and ready.  Type 'make release-push'"


.release/finish:

.release/tag:
	git tag $(TAG_PREFIX)$(VERSION_STRING)
	touch $@

.release:
	mkdir $@

release-push: UPSTREAM=$(call GIT_ORIGIN,$(RELEASE_BRANCH))
ifeq ($(UPSTREAM),)
release-push: override UPSTREAM=$(call GIT_ORIGIN,$(GIT_BRANCH))
endif

release-push:
	git push --tags $(UPSTREAM) $(RELEASE_BRANCH) 
	git push $(call GIT_ORIGIN,$(GIT_BRANCH)) $(GIT_BRANCH) 

release-abort: .release/master-checkout
	rm -rf .release

.release/merge: .release/current-branch
	git merge --no-ff -m "Merge for release" $$(cat .release/current-branch)
	touch $@

# Shell command used to produce release notes title
define RELEASE_NOTES_TITLE_TEMPLATE
( \
echo Release $(VERSION_STRING); \
echo $$(echo Release $(VERSION_STRING) | tr "[a-zA-Z0-9:, /.]" "="); \
echo \
)
endef

$(RELEASE_NOTES):  .release/title .release/changes .release/separator .release/old-notes
	cat $^ > $(RELEASE_NOTES)
	$${EDITOR:-vi} $(RELEASE_NOTES)
	git add $(RELEASE_NOTES)
	git commit -m "Updated Release notes for $(VERSION_STRING)" $(RELEASE_NOTES) version.mk

.release/title:
	$(RELEASE_NOTES_TITLE_TEMPLATE) > $@

.release/separator:
	(echo ; echo ) >> $@

.release/old-notes: 
	test -f $(RELEASE_NOTES) && cp $(RELEASE_NOTES) $@ || touch $@

.release/changes: PREVIOUS=$$(git log -n 1 --pretty=format:"%H" -- $(RELEASE_NOTES))
.release/changes:
# If release notes file already exists
	echo "Previous Release Notes revision: $(PREVIOUS)"
	test -n "$(PREVIOUS)"  && git log --no-merges $(PREVIOUS).. --pretty=format:"* %B" > $@ || git log --no-merges --pretty=format:"* %B" > $@
	test -s $@ || (echo "No changes"; rm -f $@; exit 1)

.release/checkout: .release/current-branch
	git show-ref --verify --quiet refs/heads/$(RELEASE_BRANCH) || git branch $(RELEASE_BRANCH)
	test $$(git symbolic-ref --short HEAD) == $(RELEASE_BRANCH) || git checkout $(RELEASE_BRANCH)
	touch $@

.release/current-branch:
	echo $(GIT_BRANCH) >> $@

.release/master-checkout:
	git checkout $$(cat .release/current-branch) 

info:
	@echo VERSION=$(VERSION)
	@echo VERSION_STRING=$(VERSION_STRING)
	@echo BUILD_NUMBER=$(BUILD_NUMBER)
	@echo GIT_BRANCH=$(GIT_BRANCH)
	@echo RELEASE_BRANCH=$(RELEASE_BRANCH)


