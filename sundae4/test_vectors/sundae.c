/*
SUNDAE AEAD scheme
Prepared by: Siang Meng Sim
Email: crypto.s.m.sim@gmail.com
Date: 25 Mar 2019
*/
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include "gift128.h"

//void show(uint8_t* A)
//{
//int i;
//for(i=0;i<16;i++)
//printf("%02x ",A[i]);
//printf("\n");
//
//}

void doubling(uint8_t* A) {
    /*doubling uses x^{16} + x^5 + x^3 + x + 1 at byte level*/
    uint8_t ADD=A[0];
    int i;
    for(i=0; i<15; i++) {
        A[i] = A[i+1];
    }
    A[15] = ADD;
    A[14] ^= ADD;
    A[12] ^= ADD;
    A[10] ^= ADD;

    return;
}

int sundae_enc(const uint8_t* N, unsigned long long Nlen,
               const uint8_t* A, unsigned long long Alen,
               const uint8_t* M, unsigned long long Mlen,
               const uint8_t K[16],
               uint8_t* C,
               int outputTag) {
    /*
    member 1 takes 96-bit nonce   (Nlen = 12)
    member 2 does not take in nonce (Nlen = 0)
    member 3 takes 128-bit nonce  (Nlen = 16)
    member 4 takes 64-bit nonce   (Nlen = 8)
    */

    /*
    return -1 if invalid parameter
    return 0 if encryption successful
    */

    unsigned long long i;
    const uint8_t* startM = M;
    uint8_t V[16],*AS;
    uint8_t ib[16]= {0};

    if(Alen!=0) ib[0] |= 0x80;
    if(Mlen!=0) ib[0] |= 0x40;

    if(Nlen==16) ib[0] |= 0xb0;
    else if(Nlen==12) ib[0] |= 0xa0;
    else if(Nlen==8) ib[0] |= 0x90;
    else if(Nlen!=0) return -1; /*Invalid tag length*/

    /*Prepend N to A*/
    unsigned long long ADlen = Alen+Nlen;

    uint8_t* AD = (uint8_t*)malloc(ADlen*sizeof(uint8_t));
    AS=AD;

    for(i=0; i<Nlen; i++) {
        AD[i] = N[i];
    }
    for(i=0; i<Alen; i++) {
        AD[Nlen+i] = A[i];
    }
//show(ib);

//uint8_t* V = (uint8_t*)malloc(16*sizeof(uint8_t));

    /*Initialisation*/
    giftb128(ib,K,V);
        
    //for(i=0; i<16; i++){
    //    printf("%02X", V[i]);
    //}
    //putchar('\n');

//show(V);

    /*Process AD*/
    while(ADlen>16) {
        //for(i=0; i<16; i++){
        //    printf("%02X", AD[i]);
        //}
        //putchar('\n');
	
	for(i=0; i<16; i++) {
            V[i]^=AD[i];
        }
        
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');

        giftb128(V,K,V);
        
        //for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');

        AD+=16;
        ADlen-=16;
    }

    if(ADlen==16) {
        //for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
        
	for(i=0; i<16; i++) {
            V[i]^=AD[i];
        }
	
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
        
	doubling(V);
        
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
        
	doubling(V);
        
        //for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
        
	giftb128(V,K,V);
        
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
    }
    else if(ADlen>0) {
        for(i=0; i<ADlen; i++) {
            V[i]^=AD[i];
        }

        /*10*-padding*/
        V[ADlen]^=0x80;

        doubling(V);
        
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
        
	giftb128(V,K,V);
        
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
    }
    AD=AS;
    free(AD);
    /*Process M*/
    unsigned long long Clen = Mlen;
    while(Mlen>16) {
        for(i=0; i<16; i++) {
            V[i]^=M[i];
        }

        giftb128(V,K,V);

        M+=16;
        Mlen-=16;
    }

    if(Mlen==16) {
        for(i=0; i<16; i++) {
            V[i]^=M[i];
        }

        //for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
        
	doubling(V);
        
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
        
	doubling(V);
        
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
        
	giftb128(V,K,V);
        
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');
    }
    else if(Mlen>0) {
        for(i=0; i<Mlen; i++) {
            V[i]^=M[i];
        }

        /*10*-padding*/
        V[Mlen]^=0x80;

        doubling(V);
        giftb128(V,K,V);
    }

    /*output the Tag*/
    for(i=0; i<16; i++) {
        C[i]=V[i];
    }

    if(outputTag) return 0; /*for decryption, early termination*/

    C+=16;

    /*output C*/
    M = startM;
    while(Clen>=16) {
        giftb128(V,K,V);
        for(i=0; i<16; i++) {
            C[i]=M[i]^V[i];
        }
        
	//for(i=0; i<16; i++){
        //    printf("%02X", V[i]);
        //}
        //putchar('\n');

        Clen-=16;
        C+=16;
        M+=16;
    }

    if(Clen>0) {
        giftb128(V,K,V);

        for(i=0; i<Clen; i++) {
            C[i]=M[i]^V[i];
        }
    }

    return 0;
}
