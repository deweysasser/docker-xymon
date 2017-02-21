# Track state from an external process
STATE=.running

ifneq ($(wildcard $(STATE)),$(STATE)) 
all:: $(STATE)
$(STATE)::
	@mkdir -p $@
endif

distclean::
	rm -rf $(STATE)