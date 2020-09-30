def sched_norm(k, r):
    # rotate k0 >> 12
    for i in range(r):
        k0 = k[112:128]
        k0 = k0[4:16] + k0[0:4]
   
        # rotate k1 >> 2
        k1 = k[96:112]
        k1 = k1[14:16] + k1[0:14]

        # rotate k >> 32
        k = k1 + k0 + k[0:96]
        print(frombin(''.join(k), False))
    return k

def ext_norm(k):
    ki = ['0'] * 64
    for i in range(32):
        ki[2*i]   = k[32+i]
        ki[2*i+1] = k[96+i]
    return ki

def ext_slice(k, even):
    ki = ['0'] * 64
    for i in range(32):
        if even:
            ki[2*i]   = k[1+4*i]
            ki[2*i+1] = k[2+4*i]
        else:
            ki[2*i]   = k[3+4*i]
            ki[2*i+1] = k[(4+4*i) % 128]
    return ki

def sched_slice(k, rr):
    x = k[:]
    for r in range(rr):
        for i in range(128):
            if r % 4 == 0:
                # reversal (part 2)
                if i == 0 and r > 0:
                    x = swap(x, 0, 127)
    
                # k1 << 2 
                if i >= 11 and i <= 63 and i % 4 == 3:
                    x = swap(x, 119, 127)
                
                if r != 0:
                    # k7 <<< 8
                    if i >= 3 and i <= 31 and i % 4 == 3:
                        x = swap(x, 0, 32)
                    # k7 << 4
                    if i >= 20 and i <= 64 and i % 4 == 0:
                        x = swap(x, 111, 127)
                    # k6 << 4 (part 1)
                    if i >= 84 and i <= 128 and i % 4 == 0:
                        x = swap(x, 111, 127)
    
            elif r % 4 == 1:
                 # k6 << 4 (part 2)
                 if r != 1:
                    if i == 0:
                        x = swap(x, 111, 127)
              
                 # k3 << 2
                 if i >= 13 and i <= 65 and i % 4 == 1:
                    x = swap(x, 119, 127)
    
                 # k1 <<< 8
                 if i >= 2 and i <= 30 and i % 4 == 2:
                     x = swap(x, 0, 32)
                 # k1 << 4
                 if i >= 19 and i <= 63 and i % 4 == 3:
                     x = swap(x, 111, 127)
                 # k0 << 4
                 if i >= 83 and i <= 127 and i % 4 == 3:
                     x = swap(x, 111, 127)
    
            if r % 4 == 2:
                # reversals
                if i % 4 == 0:
                    x = swap(x, 1, 2)
                if i % 4 == 2:
                    x = swap(x, 0, 127)
                
                # k5 << 2
                if i >= 10 and i <= 62 and i % 4 == 2:
                    x = swap(x, 119, 127)
            
                # k3 << 8
                if i >= 4 and i <= 32 and i % 4 == 0:
                    x = swap(x, 0, 32)
                # k3 << 4
                if i >= 21 and i <= 65 and i % 4 == 1:
                    x = swap(x, 111, 127)
                # k2 << 4 (part 1)
                if i >= 85 and i <= 128 and i % 4 == 1:
                    x = swap(x, 111, 127)
            
            if r % 4 == 3:
                # reversals (part 1)
                if i % 4 == 0: 
                    x = swap(x, 3, 4)
                if i % 4 == 0 and i > 0:
                    x = swap(x, 0, 127)
                
                # k2 << 4 (part 2)
                if i == 1:
                    x = swap(x, 111, 127)
                
                # k7 << 2 
                if i >= 12 and i <= 64 and i % 4 == 0:
                   x = swap(x, 119, 127)
                
                # k5 << 8
                if i >= 1 and i <= 29 and i % 4 == 1:
                    x = swap(x, 0, 32)
                # k5 << 4
                if i >= 18 and i <= 62 and i % 4 == 2:
                    x = swap(x, 111, 127)
                # k4 << 4
                if i >= 82 and i <= 128 and i % 4 == 2:
                    x = swap(x, 111, 127)
    
            x = rotate_left(x)
    return x
  
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

def slice_order_inv(k):
    ki = ['0'] * 128

    for i in range(0, 16):
        ki[32+i] = k[1+4*i]  # k5
        ki[96+i] = k[2+4*i]  # k1
        ki[0+i]  = k[3+4*i]  # k7
        ki[64+i] = k[4+4*i]  # k3
        
        ki[48+i]  = k[64+1+4*i]         # k4
        ki[112+i] = k[64+2+4*i]         # k0
        ki[16+i]  = k[64+3+4*i]         # k6
        ki[80+i]  = k[(64+4+4*i) % 128] # k2

    return ki

def rotate_left(x):
    return x[1:] + [x[0]]

def swap(x, i, j):
    tmp = x[i]
    x[i] = x[j]
    x[j] = tmp
    return x

def tobin(x, k):
    if k:
        return '{0:064b}'.format(x)
    else:
        return '{0:0128b}'.format(x)

def frombin(x, k):
    if k:
        return '{0:016X}'.format(int(x, 2)) 
    else:
        return '{0:032X}'.format(int(x, 2)) 

# k = [i for i in range(128)]

# x = 0x000102030405060708090A0B0C0D0E0F
x = 0x0123456789ABCDEFFEDCBA9876543210
k = list('{0:0128b}'.format(x))


kt = ext_norm(k)
kt1 = ext_slice(slice_order(k), True)
print(frombin(''.join(kt), True))
print(frombin(''.join(kt1), True))

k1 = sched_norm(k, 9)
k1e = ext_norm(k1)
print(frombin(''.join(k1e), True))

k11 = sched_slice(slice_order(k), 10)
k11e = ext_slice(k11, False)
print(frombin(''.join(k11e), True))

