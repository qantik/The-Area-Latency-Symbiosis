#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#include "gift128.h"

void rand_vec(uint8_t *vec, int n) {
    for (int i = 0; i < n; i++) vec[i] = rand() % 256;
}

void print_vec(FILE *in, uint8_t *vec, int n, char *label) {
    fprintf(in, "%s", label);
    for (int i = 0; i < n; i++) fprintf(in, "%02X", vec[i]);
    fprintf(in, "\n");
}

int main(void) {
    FILE *in0 = fopen("Testinput.txt", "w");
    FILE *out1 = fopen("Testoutput.txt", "w");
    
    //8B8253BB8C1501690CB7BC73761C41ED
    //45E51675F47195463286B09F0D58B798
    /* uint8_t k[16] = {0x8B, 0x82, 0x53, 0xBB, 0x8C, 0x15, 0x01, 0x69, 0x0C, 0xB7, 0xBC, 0x73, 0x76, 0x1C, 0x41, 0xED}; */
    /* uint8_t p[16] = {0x45, 0xE5, 0x16, 0x75, 0xF4, 0x71, 0x95, 0x46, 0x32, 0x86, 0xB0, 0x9F, 0x0D, 0x58, 0xB7, 0x98}; */
    /* uint8_t k[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F}; */
    /* uint8_t p[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F}; */
    /* uint8_t c[16]; */
    /* giftb128(p, k, c); */
    /* print_vec(in0, k, 16, ""); */
    /* print_vec(in0, p, 16, ""); */
    /* print_vec(out1, c, 16, ""); */
    
    /* time(time()); */
    srand(3200);

    for (int i = 0; i < 100; i++) {
        uint8_t k[16]; rand_vec(k, 16);
        uint8_t p[16]; rand_vec(p, 16);
        uint8_t c[16]; giftb128(p, k, c);

		print_vec(in0, k, 16, "");
        print_vec(in0, p, 16, "");
        print_vec(out1, c, 16, "");
    }
    
    fclose(in0);
	fclose(out1);
    
    return EXIT_SUCCESS;
}
