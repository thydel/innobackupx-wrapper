top:; @date

self := innobackupex
bin := /usr/local/bin

. := $(or $(filter $(shell id -u), 0), $(error you are not root))

install := $(bin)/$(self).sh
$(install): $(self).sh; install -o root -g root -m 755 --backup=t $< $@
install: $(install);
