CC = gcc
CFLAGS = -Wall -pedantic

DEPS = gift128.h
OBJ = main.o gift128.o

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

main: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -f main *.o

