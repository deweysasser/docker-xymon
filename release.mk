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
VERSION?=$(shell date -u "+%Y/%m/%d %H:%M:%S")
VERSION_STRING?=$(VERSION)
VERSION_TAG=$(shell echo -n $(strip $(VERSION_STRING)) | tr -c "A-Za-z0-9_-" ".")

# The current branch
GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

TAG_PREFIX=$(GIT_BRANCH)/

# How to look up the origin of a branch
define GIT_ORIGIN
$(shell (git rev-parse --abbrev-ref --symbolic-full-name $1@{push} | awk -F/ '{print $$1}'))
endef

ifdef SUPPRESS_RELEASE
release:
	@echo "Use one of:  make major-release, make minor-release, make patch-release"
	@exit 1
else
release: minor-release
endif

# Nothing to do for this one
version-bump:

major-release minor-release patch-release: .release .release/checkout .release/merge 
	make version-bump VERSION_LEVEL=$(subst -release,,$@)
	make $(RELEASE_NOTES) .release/tag .release/master-checkout
	rm -rf .release
	echo "Release merged and ready.  Type 'make release-push'"


.release/finish:

.release/tag:
	git tag $(TAG_PREFIX)$(VERSION_TAG)
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
echo $$(echo Release $(VERSION_STRING) | tr -c "=" "="); \
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
	@echo VERSION_TAG=$(VERSION_TAG)
	@echo TAG to be applied = $(TAG_PREFIX)$(VERSION_TAG)
	@echo BUILD_NUMBER=$(BUILD_NUMBER)
	@echo GIT_BRANCH=$(GIT_BRANCH)
	@echo RELEASE_BRANCH=$(RELEASE_BRANCH)


