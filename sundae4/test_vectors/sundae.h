#ifndef SUNDAE_H
#define SUNDAE_H

#include <stdint.h>

int sundae_enc(const uint8_t* N, unsigned long long Nlen,
                const uint8_t* A, unsigned long long Alen,
                const uint8_t* M, unsigned long long Mlen,
                const uint8_t K[16],
                uint8_t* C,
                int outputTag);

#endif
