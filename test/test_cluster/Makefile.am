# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

CFLAGS=-I../include -g3 -DNDEBUG
CXXFLAGS=-I../include -g3 -DNDEBUG
# FCFLAGS=-m64

if DEBUG
override CFLAGS=-DDEBUG -g -femit-struct-debug-baseonly -Wall -Werror -Wextra -03
override CXXFLAGS=-DDEBUG -g -femit-struct-debug-baseonly -Wall -Werror -Wextra -03
endif

CC=mpicc $(CFLAGS)
CXX=mpic++ $(CXXFLAGS)

all:
	$(CC) -o bin/hello_mpi src/hello_mpi.c
	$(CXX) -o bin/prime_check src/prime_check.c
if !DEBUG
	strip -d bin/hello_mpi
	strip -d bin/prime_check
endif

clean :
	@for trash in bin/hello_mpi bin/prime_check Makefile Makefile.in;do \
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done
