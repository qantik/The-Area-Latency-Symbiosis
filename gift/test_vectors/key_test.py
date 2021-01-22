def sched_norm(k, r):
    for i in range(r):
        # rotate k0 >> 12
        k0 = k[112:128]
        k0 = k0[4:16] + k0[0:4]
   
        # rotate k1 >> 2
        k1 = k[96:112]
        k1 = k1[14:16] + k1[0:14]

        # rotate k >> 32
        k = k1 + k0 + k[0:96]
    return k

def ext_norm(k):
    ki = ['0'] * 64
    for i in range(32):
        ki[2*i]   = k[32+i] # k5|k4
        ki[2*i+1] = k[96+i] # k1|k0
    return ki

def slice_order(k):
    ki = ['0'] * 128

    for i in range(0, 16):
        ki[1+4*i] = k[32+i]  # k5
        ki[2+4*i] = k[96+i]  # k1
        ki[3+4*i] = k[0+i]   # k7
        ki[4+4*i] = k[64+i]  # k3
        
        ki[64+1+4*i] = k[48+i]         # k4
        ki[64+2+4*i] = k[112+i]        # k0
        ki[64+3+4*i] = k[16+i]         # k6
        ki[(64+4+4*i) % 128] = k[80+i] # k2

    return ki

def rotate_left(x, b):
    return x[1:] + [b]

def tobin(x, k=False):
    if k: return '{0:064b}'.format(x)
    else: return '{0:0128b}'.format(x)

def frombin(x, k=False):
    if k: return '{0:016X}'.format(int(x, 2)) 
    else: return '{0:032X}'.format(int(x, 2)) 

def sched_slice(k, rounds):
    x = ['-'] * 128
    rk = [[] for i in range(rounds)]
    for r in range(-1, rounds):
        for c in range(128):
            if r > -1 : print(r, c, frombin(''.join(x), False))

            if r == -1:
                b = k[c]
            else:
               
                # Extract round key
                if r % 4 == 0 and (c % 4 == 1 or c % 4 == 2):
                    rk[r].append(x[0])
                elif r % 4 == 1 and (c % 4 == 1 or c % 4 == 2):
                    rk[r].append(x[2])
                elif r % 4 == 2:
                    if c % 4 == 1:
                        rk[r].append(x[1])
                    elif c % 4 == 2:
                        rk[r].append(x[127])
                elif r % 4 == 3:
                    if c % 4 == 1:
                        rk[r].append(x[3])
                    elif c % 4 == 2:
                        rk[r].append(x[1])

                if r % 4 == 1 and c == 1:
                    # k1 >> 2
                    t = [x[1+4*i] for i in range(16)]
                    for i in range(16): x[1+4*i] = t[(14+i) % 16] 
                    
                    # k0 >> 12
                    t = [x[(1+64+4*i)%128] for i in range(16)]
                    for i in range(16): x[(1+64+4*i)%128] = t[(4+i) % 16]
                
                if r % 4 == 2 and c == 3:
                    # k3 >> 2
                    t = [x[(1+4*i)%128] for i in range(16)]
                    for i in range(16): x[1+4*i] = t[(14+i) % 16] 
                    
                    # k2 >> 12
                    t = [x[(1+64+4*i)%128] for i in range(16)]
                    for i in range(16): x[1+64+4*i] = t[(4+i) % 16]
                
                if r % 4 == 3 and c == 0:
                    # k5 >> 2
                    t = [x[(1+4*i)%128] for i in range(16)]
                    for i in range(16): x[1+4*i] = t[(14+i) % 16] 
                    
                    # k4 >> 12
                    t = [x[(1+64+4*i)%128] for i in range(16)]
                    for i in range(16): x[1+64+4*i] = t[(4+i) % 16]
                
                if r % 4 == 0 and c == 2 and r > 0:
                    # k7 >> 2
                    t = [x[(1+4*i)%128] for i in range(16)]
                    for i in range(16): x[1+4*i] = t[(14+i) % 16] 
                    
                    # k6 >> 12
                    t = [x[(1+64+4*i)%128] for i in range(16)]
                    for i in range(16): x[1+64+4*i] = t[(4+i) % 16]
                
                b = x[0]
                
            x = rotate_left(x, b)

            # print(r, i, x)
    return x, rk

x = 0xF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0
# x = 0x000102030405060708090A0B0C0D0E0F
k = list('{0:0128b}'.format(x))

r = 5

sk = sched_norm(k, r-1)
rk = ext_norm(sk)
print(frombin(''.join(rk), True))

sk, rk = sched_slice(slice_order(k), r)
print(frombin(''.join(rk[r-1]), True))
