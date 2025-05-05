CFLAGS=-g -Wall -Wextra -pedantic -std=c99 # $(shell pkg-config --cflags gtk+-2.0)
# LDFLAGS=$(shell pkg-config --libs gtk+-2.0)
INC=-I/home/franklin/workspace/lab-franklin/src/gui-test/include # -I/usr/include/gtk-2.0 -I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/lib64/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng12


all:
	$(CC) $(CFLAGS) src/main.c -o build/gui-test $(INC)
#$(CC)    $(CFLAGS) src/main.c -o build/gui-test $(LDFLAGS) $(INC)

clean:
	rm configure.scan autoscan.log bin/gui-test
