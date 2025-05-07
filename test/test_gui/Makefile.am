# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

CFLAGS=-I../include -g3 -DNDEBUG
CXXFLAGS=-I../include -g3 -DNDEBUG

if DEBUG
override CFLAGS=-DDEBUG -g -femit-struct-debug-baseonly -Wall -Werror -Wextra -03
override CXXFLAGS=-DDEBUG -g -femit-struct-debug-baseonly -Wall -Werror -Wextra -03
endif

CC=mpicc $(CFLAGS)
CXX=mpic++ $(CXXFLAGS)
SRC=src/main.c

# CFLAGS=-g -Wall -Wextra -pedantic -std=c99 # $(shell pkg-config --cflags gtk+-2.0)
# LDFLAGS=$(shell pkg-config --libs gtk+-2.0)

INC=-I/home/franklin/workspace/lab-franklin/src/gui-test/include -I/usr/lib/arm-linux-gnueabihf/openmpi/include
# -I/usr/include/gtk-2.0 -I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include
# -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/lib64/glib-2.0/include
# -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng12

all:
#$(CC) $(CFLAGS) src/main.c -o bin/gui-test $(INC)
	$(CC) $(SRC) -o bin/gui-test $(INC)
#$(CC)    $(CFLAGS) src/main.c -o bin/gui-test $(LDFLAGS) $(INC)
if !DEBUG
	strip -d bin/gui_test
endif

clean:
if HAS_DOCKER
	docker system prune -f
endif
	rm -rf *.egg-info
	find . -name '*.pyc' | xargs rm -rf
	find . -name '__pycache__' | xargs rm -rf
	for trash in config.log config.status config.h.in configure configure~ configure.scan autoscan.log bin/gui-test;do \
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done