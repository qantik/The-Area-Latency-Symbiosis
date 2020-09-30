CC = gcc
CFLAGS = -std=c99 -Wall -pedantic

DEPS = skinny_reference.h skinny_aead.h
OBJ = main.o skinny_reference.c skinny_aead.c 

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

main: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

run:
	rm -f SKINNY_TBC_detailed_TV.txt && ./main

.PHONY: clean
clean:
	rm -f main *.o
