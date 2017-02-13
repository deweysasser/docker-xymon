# Track state from an external process
STATE=.running

all:: $(STATE)

$(STATE):
	mkdir -p $@

