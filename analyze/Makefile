
CC = g++ -O2 -std=c++11

CFLAGS = -I. -g -Wall
LDFLAGS = -L.

PROG_OBJS = \
	hash_table.o \
	utility.o

DEPS = 

default: all
all: check_hash match_unknown

%.o:%.cc $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

check_hash: check_hash.o $(PROG_OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

match_unknown: match_unknown.o $(PROG_OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

.PHONY: clean squeaky

clean: 
	/bin/rm -f *.o check_hash match_unknown

squeaky: clean
	/bin/rm -f *~ *.bak 

# dependencies

check_hash.o: check_hash.cc hash_table.h
match_unknown.o: match_unknown.cc hash_table.h
hash_table.o: hash_table.cc hash_table.h utility.h
utility.o: utility.cc utility.h
