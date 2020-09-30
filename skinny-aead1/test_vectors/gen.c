#include<stdio.h>
#include<stdlib.h>

static unsigned long long block_count = 0;
static unsigned long long ad_count = 0;
static unsigned long long ae_count = 0;

/* I assume the following:
    block contains valid 2 bytes, and the rest is padded with 10*
*/
void pad(unsigned char* block) {
    int i;
    block[2] = 0x80;
    for(i = 3; i<16; i++) block[i] = 0x00;
}
/* I assume the following:
    block contains valid 2 bytes, and the rest is padded with 10*
*/
void pad_alt(unsigned char* block) {
    int i;
    block[14] = block[0];
    block[15] = block[1];
    block[13] = 0x01;
    for(i = 0; i<13; i++) block[i] = 0x00;
}

void print_bytes(FILE *f, unsigned char* block, unsigned long long len) {
    int i;
	for(i=0; i<len ;i++) fprintf(f, "%02X", block[i]); 
    fprintf(f, "\n");
}

void generate_ae_inputs(unsigned char *m, unsigned long long *mlen,
	unsigned char *ad, unsigned long long *adlen,
	unsigned char *npub,
	unsigned char *k, unsigned char *incomplete_ad, unsigned char*incomplete_m )
{
    int i;
    do {
        *mlen = (unsigned long long) rand()%9;
        *adlen = (unsigned long long) rand()%2;    
    } while (*adlen + *mlen == 0);

    *incomplete_ad = rand()%2 == 0 ? 0x00 : 0x01;
    *incomplete_m = rand()%2 == 0 ? 0x00 : 0x01;

    for(i=0; i<16; i++) npub[i] = rand() % 256;
    for(i=0; i<16; i++) k[i] = rand() % 256;
    for(i=0; i<16*(*mlen); i++) m[i] = rand() % 256;
    for(i=0; i<16*(*adlen); i++) ad[i] = rand() % 256;
    
    // pad if incomplete
    if (*incomplete_ad == 0x01 && *adlen >0) {
        pad(ad + 16*(*adlen - 1));
	}
	if (*incomplete_m == 0x01 && *mlen >0) {
        pad(m + 16*(*mlen - 1));
	}
}


void save_aead(FILE *in,
    unsigned char *m, unsigned long long *mlen,
	unsigned char *ad, unsigned long long *adlen,
	unsigned char *npub,
	unsigned char *k, unsigned char* incomplete_ad, unsigned char* incomplete_m)
{
    int j;
	fprintf(in, "%d ", (int) *adlen);
	fprintf(in, "%d ", (int) *mlen);
	fprintf(in, "%d ", (int) *incomplete_ad);
	fprintf(in, "%d\n", (int) *incomplete_m);

    print_bytes(in, k, 16);
    print_bytes(in, npub, 16);
    for(j=0; j<*adlen; j++) print_bytes(in, ad+16*j, 16);
    for(j=0; j<*mlen;  j++) print_bytes(in, m+16*j, 16);
    //for(j=0; j<*mlen;  j++) print_bytes(in, m+16*j, 16);
    
    block_count += *mlen;
    ad_count += *adlen;
    ae_count += 1;

}

int main() {

	FILE *in = fopen("IN_1000", "w");
    srand(0); // seed randomness source
    
    unsigned char m[128]; // so we can accommodate 128*8 bits
    unsigned char k[16]; // assuming key is 128 bits
    unsigned char ad[16]; // assuming ad is at most 128 bits
    unsigned char npub[16]; // assuming nonce is at most 128 bits
    
    unsigned long long mlen, adlen;
    unsigned char incomplete_ad, incomplete_m;
    int j;
    
	
	for(j=0; j<1000; j++) {	fprintf(in, "%d ", j);
	    generate_ae_inputs(m, &mlen, ad, &adlen, npub, k, &incomplete_ad, &incomplete_m);
	    save_aead(in, m, &mlen, ad, &adlen, npub, k, &incomplete_ad, &incomplete_m);
	}

	fclose(in);

    printf("# of ae calls   = %llu\n", ae_count);
    printf("# of ad blocks  = %llu\n", ad_count);
    printf("# of msg blocks = %llu\n", block_count);
}
