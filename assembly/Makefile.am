clean:
	@for trash in src/hello src/*.o AUTHORS ChangeLog NEWS aclocal.m4 autom4te.cache config config.log config.status configure configure~ libtool; do\
                if [ -f $$trash ] || [ -d $$trash ]; then \
                        echo "Removing $$trash" ;\
                        rm -rf $$trash ;\
                fi ; \
        done
