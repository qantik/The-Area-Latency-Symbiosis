#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#include "gift128.h"

void rand_vec(uint8_t *vec, int n) {
    for (int i = 0; i < n; i++) vec[i] = rand() % 256;
}

void print_vec(uint8_t *vec, int n, char *label) {
    printf("%s", label);
    for (int i = 0; i < n; i++) printf("%02X", vec[i]);
    putchar('\n');
}

int main(void) {
    /* uint8_t pt[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F}; */
    /* uint8_t key[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F}; */
    /* uint8_t ct[16]; */
    /* giftb128(pt, key, ct); */
    /* for (int i = 0; i < 16; i++) { */
    /*     printf("%02X", ct[i]); */
    /* } */
    /* putchar('\n'); */

    time(0);

    for (int i = 0; i < 100; i++) {
        uint8_t k[16]; rand_vec(k, 16);
        uint8_t p[16]; rand_vec(p, 16);
        uint8_t c[16]; giftb128(p, k, c);

        print_vec(k, 16, "");
        print_vec(p, 16, "");
        print_vec(c, 16, "");
        putchar('\n');
    }
    
    return EXIT_SUCCESS;
}
