#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "skinny_aead.h"

void rand_vec(uint8_t *vec, int n) {
    for (int i = 0; i < n; i++) vec[i] = rand() % 256;
}

void print_vec(uint8_t *vec, int n) {
    for (int i = 0; i < n; i++) printf("%02X", vec[i]);
    putchar('\n');
}

int main(void) {
    //uint8_t a[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F};
    //uint8_t p[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F};
    //uint8_t k[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F};
    //uint8_t n[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F};
    //uint8_t c[16+16]; size_t cl;

    ////uint8_t ad[32]; memcpy(ad, a, 16); memcpy(ad+16, a, 8); //memcpy(ad+32, a, 16);

    //printf("0 1 1 0 0\n");
    //print_vec(k, 16);
    //print_vec(n, 16);
    //print_vec(a, 16);
    //print_vec(p, 16);
    //
    //skinny_aead_encrypt(a, 16, p, 16, k, n, c, &cl);
    //for (int i = 0; i < 16; i++) {
    //    printf("%02X", c[i+16]);
    //}
    //putchar('\n');
    
    srand(101);
    
    int al = 40; //rand() % 64;
    int pl = 40; //rand() % 16;
    
    int a_part = al % 16 == 0 ? 0 : 1;
    int p_part = pl % 16 == 0 ? 0 : 1;
    
    int al_pad = a_part ? 16*(1+al/16) : al; 
    int pl_pad = p_part ? 16*(1+pl/16) : pl;
    size_t cl;
    
    uint8_t k[16]; rand_vec(k, 16);
    uint8_t n[16]; rand_vec(n, 16);
    uint8_t a[al_pad]; memset(a, 0, al_pad); rand_vec(a, al);
    uint8_t p[pl_pad]; memset(p, 0, pl_pad); rand_vec(p, pl);
    uint8_t c[cl];
    
    uint8_t va[al_pad]; memcpy(va, a, al_pad);
    uint8_t vp[pl_pad]; memcpy(vp, p, pl_pad);
    
    skinny_aead_encrypt(a, al, p, pl, k, n, c, &cl);
    
    if (a_part) va[al] ^= 0x80; // pad
    if (p_part) vp[pl] ^= 0x80; // pad
    
    printf("0 %d %d %d %d\n", al_pad/16, pl_pad/16, a_part, p_part);   
    print_vec(k, 16);
    print_vec(n, 16);
    for (int i = 0; i < al_pad; i += 16) print_vec(&va[i], 16);
    for (int i = 0; i < pl_pad; i += 16) print_vec(&vp[i], 16);
    print_vec(c+pl, 16);
    
    return EXIT_SUCCESS;
}
