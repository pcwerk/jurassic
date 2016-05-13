
CC = g++ -O2

CFLAGS = -I. -g -Wall
LDFLAGS = -L.

CSO_PROG_OBJS = \
	hash_table.o \
	utility.o

DEPS = 

default: check_hash

%.o:%.cc $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

check_hash: check_hash.o $(CSO_PROG_OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)


.PHONY: clean

clean: 
	/bin/rm -f *.o check_hash

squeaky: clean
	/bin/rm -f *~ *.bak 

# dependencies

check_hash.o: check_hash.cc hash_table.h
hash_table.o: hash_table.cc hash_table.h utility.h
utility.o: utility.cc utility.h
