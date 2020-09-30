CC = gcc
CFLAGS = -std=c99 -Wall -pedantic

DEPS = gift128.h sundae.h
OBJ = main.o gift128.o sundae.c

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

main: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -f main *.o

