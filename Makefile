prefix ?= /usr/local
gitdir ?= $(shell git --exec-path)

gitver ?= $(word 3,$(shell git --version))

INSTALL ?= install
INSTALL_DATA = $(INSTALL) -c -m 0644
INSTALL_EXE = $(INSTALL) -c -m 0755
INSTALL_DIR = $(INSTALL) -c -d -m 0755

default:
	@echo "git-playback doesn't need to be built."
	@echo "Just copy it (including playback.css and playback.js) somewhere on your PATH, like /usr/local/bin."
	@false

install: install-exe install-js install-css

install-exe: git-playback.sh
	$(INSTALL_DIR) $(DESTDIR)/$(gitdir)
	$(INSTALL_EXE) $< $(DESTDIR)/$(gitdir)/git-playback

install-js: playback.js
	$(INSTALL_DIR) $(DESTDIR)/$(gitdir)
	$(INSTALL_DATA) $< $(DESTDIR)/$(gitdir)

install-css: playback.css
	$(INSTALL_DIR) $(DESTDIR)/$(gitdir)
	$(INSTALL_DATA) $< $(DESTDIR)/$(gitdir)
