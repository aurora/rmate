BIN ?= rmate
PREFIX ?= /usr/local
prefix ?= $(PREFIX)
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin

install:
	cp rmate $(bindir)/$(BIN)

uninstall:
	rm -f $(bindir)/$(BIN)

.PHONY: install uninstall
