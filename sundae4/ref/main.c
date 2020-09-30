#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "sundae.h"
#include "gift128.h"

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
    //uint8_t c[16+16];
    //
    //sundae_enc(n, 0, a, 16, p, 16, k, c, 0);
    //for (int i = 0; i < 16; i++) {
    //    printf("%02X", c[i]);
    //}
    //putchar('\n');

    srand(135);
    
    const int nonces[4] = {0, 8, 12, 16};

    int nl = 0; //nonces[rand() % 4];
    int al = 8; // rand() % 32;
    int pl = 48;  //rand() % 64;

    int n_part = nl % 16 == 0 ? 0 : 1;
    int a_part = al % 16 == 0 ? 0 : 1;
    int p_part = pl % 16 == 0 ? 0 : 1;

    int nl_pad = n_part ? 16*(1+nl/16) : nl; 
    int al_pad = a_part ? 16*(1+al/16) : al; 
    int pl_pad = p_part ? 16*(1+pl/16) : pl;
    int cl = pl_pad + 16;

    uint8_t k[16]; rand_vec(k, 16);
    uint8_t n[nl_pad]; memset(n, 0, nl_pad); rand_vec(n, nl);
    uint8_t a[al_pad]; memset(a, 0, al_pad); rand_vec(a, al);
    uint8_t p[pl_pad]; memset(p, 0, pl_pad); rand_vec(p, pl);
    uint8_t c[cl];
    
    sundae_enc(n, nl, a, al, p, pl, k, c, 0);
    
    int val = nl + al;
    int va_part = val % 16 == 0 ? 0 : 1;
    int val_pad = va_part ? 16*(1+val/16) : val;

    uint8_t init[16] = {0};
    if (al != 0) init[0] ^= 0x80;
    if (pl != 0) init[0] ^= 0x40;
    if (nl == 8) init[0] ^= 0x10;
    else if (nl == 12) init[0] ^= 0x20;
    else if (nl == 16) init[0] ^= 0x30;

    uint8_t va[val_pad]; memset(va, 0, val_pad);
    memcpy(va, n, nl); memcpy(va+nl, a, al);
    if (val % 16 != 0) va[val] ^= 0x80; // pad
    //print_vec(va, 32);

    uint8_t vp[pl_pad]; memset(vp, 0, pl_pad);
    memcpy(vp, p, pl);
    if (pl % 16 != 0) vp[pl] ^= 0x80; // pad
    
    //printf("%d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", nl, al, pl, n_part, a_part, p_part, nl_pad, al_pad, pl_pad, cl);   
    printf("0 %d %d %d %d\n", val_pad/16, pl_pad/16, va_part, p_part);   

    print_vec(init, 16);
    print_vec(k, 16);
    for (int i = 0; i < val_pad; i += 16) print_vec(&va[i], 16);
    for (int i = 0; i < pl_pad; i += 16) print_vec(&vp[i], 16);
    print_vec(c, 16);
    for (int i = 0; i < pl_pad; i += 16) print_vec(&vp[i], 16);
    //print_vec(c+16, 16);
    
    return EXIT_SUCCESS;
}
