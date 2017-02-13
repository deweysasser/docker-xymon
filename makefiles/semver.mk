# Each versioning module must supply the variable VERSION
# Optionally, it may supply VERSION_STRING as well, which would
# include the .rc or .alpha part
# It must also supply a recipe for "bump" that uses make variable
# VERSION_LEVEL appropriately


# Store all version numbers in an external file
include version.mk

# Make sure 'make release' by itself doesn't work
SUPPRESS_RELEASE=true

ifeq ($(VPATCH), 0)
VERSION=$(VMAJOR).$(VMINOR)
else
VERSION=$(VMAJOR).$(VMINOR).$(VPATCH)
endif


TAG_PREFIX=$(GIT_BRANCH)/

VERSION_STRING=$(VERSION)

version-bump:  $(VERSION_LEVEL)-bump

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
