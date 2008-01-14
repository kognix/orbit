# $Id: Makefile,v 1.3 2008/01/14 02:07:38 mascarenhas Exp $

include config

all:

config:
	touch config

install:
	mkdir -p $(LUA_DIR)
	cp src/orbit.lua $(LUA_DIR)
	mkdir -p $(LUA_DIR)/orbit
	cp src/model.lua $(LUA_DIR)/orbit
	cp src/cache.lua $(LUA_DIR)/orbit
	mkdir -p $(BIN_DIR)
	cp src/orbit $(BIN_DIR)
	if [ -f ./wsapi/Makefile ]; then \
	  cd wsapi && make install; \
	fi

install-rocks: install
	mkdir -p $(PREFIX)/samples
	cp -r samples/* $(PREFIX)/samples
	mkdir -p $(PREFIX)/doc
	cp -r doc/* $(PREFIX)/doc
	mkdir -p $(PREFIX)/test
	cp -r test/* $(PREFIX)/test

clean:
