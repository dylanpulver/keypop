PREFIX ?= /usr/local

.PHONY: test lint install uninstall

test:
	./test-parse.sh
	./test-behavior.sh

lint:
	shellcheck --severity=warning keypop test-parse.sh test-behavior.sh

install:
	install -d "$(PREFIX)/bin"
	ln -sf "$(CURDIR)/keypop" "$(PREFIX)/bin/keypop"
	@echo "linked keypop -> $(PREFIX)/bin/keypop"

uninstall:
	rm -f "$(PREFIX)/bin/keypop"
