CFLAGS=-I../include -g3 -DNDEBUG
CXXFLAGS=-I../include -g3 -DNDEBUG

if DEBUG
override CFLAGS=-DDEBUG -g -femit-struct-debug-baseonly -Wall -Werror -Wextra -03
override CXXFLAGS=-DDEBUG -g -femit-struct-debug-baseonly -Wall -Werror -Wextra -03
endif

CC=mpicc $(CFLAGS)
CXX=mpic++ $(CXXFLAGS)

EXECUTABLE = prime_check
OBJECTS = prime_check.o

all: $(EXECUTABLE)
	$(CC) -o hello_mpi hello_mpi.c
if !DEBUG
strip -d hello_mpi
strip -d prime_check
endif

$(EXECUTABLE): $(OBJECTS)
	$(CXX) -o $@ $^ -lfl

clean :
	@for trash in hello_mpi prime_check Makefile Makefile.in;do \
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done
