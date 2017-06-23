BIN ?= rmate
PREFIX ?= /usr/local

install:
	cp rmate $(PREFIX)/bin/$(BIN)

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)

.PHONY: install uninstall
