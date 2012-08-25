prefix ?= /usr/local
gitdir ?= $(shell git --exec-path)

gitver ?= $(word 3,$(shell git --version))

default:
	@echo "git-playback doesn't need to be built."
	@echo "Just copy it (including git-playback.css and git-playback.js) somewhere on your PATH, like /usr/local/bin."
	@echo "This can also be done by running 'make install'"
	@false

install: uninstall
	@mkdir $(DESTDIR)/$(gitdir)/git-playback.js/
	@mkdir $(DESTDIR)/$(gitdir)/git-playback.css/
	cp -f git-playback.js/*.js $(DESTDIR)/$(gitdir)/git-playback.js/
	cp -f git-playback.css/*.css $(DESTDIR)/$(gitdir)/git-playback.css/
	cp -f git-playback.sh $(DESTDIR)/$(gitdir)/git-playback

uninstall:
	@rm -rf $(DESTDIR)/$(gitdir)/git-playback.css/
	@rm -rf $(DESTDIR)/$(gitdir)/git-playback.js/
	@rm -f $(DESTDIR)/$(gitdir)/git-playback
