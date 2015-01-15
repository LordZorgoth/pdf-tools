EMACS = emacs
EFLAGS = -Q -L $(PWD)/lisp --batch 

.PHONY: all clean distclean package bytecompile test check melpa

all: server/epdfinfo

clean: 
	rm -rf dist
	rm -f -- lisp/*.elc
	$(MAKE) -C server clean

distclean: clean
	[ -f server/Makefile ] && $(MAKE) -C server distclean
	rm -rf -- .cask

package: all
	cask package

server/epdfinfo: server/Makefile
	$(MAKE) -C server
server/Makefile: server/configure
	cd server && ./configure -q
server/configure: server/configure.ac
	cd server && ./autogen.sh

bytecompile: 
	cask exec $(EMACS) $(EFLAGS) -f batch-byte-compile lisp/*.el

test: all
	cask exec $(EMACS) $(EFLAGS) -l test/run-tests.el 

check: bytecompile test

install-server-deps:
	sudo apt-get install gcc g++ make automake autoconf \
		libpng-dev libz-dev libpoppler-glib-dev
	-sudo apt-get install libpoppler-private-dev

melpa: all
	cp -p server/epdfinfo .
	$(MAKE) distclean
	@if [ -x epdfinfo ]; then \
		echo "Server successfully build."; \
	else \
		echo "Server not build, maybe due to missing dependencies (See README)."; \
		echo "Required: gcc g++ make automake autoconf libpng-dev libz-dev libpoppler-glib-dev libpoppler-private-dev"; \
		false; \
	fi
