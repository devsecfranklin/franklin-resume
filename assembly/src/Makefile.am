CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal

.PHONY: test

asm_hello.o:
	yasm -felf64  -gdwarf2 asm_hello.asm
	ld -g -o hello asm_hello.o

clean:
	@for trash in hello *.o; do\
                if [ -f $$trash ] || [ -d $$trash ]; then \
                        echo "Removing $$trash" ;\
                        rm -rf $$trash ;\
                fi ; \
        done
