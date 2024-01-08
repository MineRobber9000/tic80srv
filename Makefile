SOURCES     := $(wildcard *.moon) $(wildcard tic/*.moon) $(wildcard models/*.moon) $(wildcard users/*.moon) $(wildcard widgets/*.moon)
LUA_SOURCES := $(patsubst %.moon, %.lua, $(SOURCES))

all: $(LUA_SOURCES)

%.lua: %.moon
	moonc -o $@ $<

.PHONY: server clean clean_server

ENV := development

server: all
	lapis server $(ENV)

clean: clean_server clean_lua

clean_server:
	rm -rf *_temp logs nginx.conf.compiled

clean_lua:
	rm -rf $(LUA_SOURCES)
