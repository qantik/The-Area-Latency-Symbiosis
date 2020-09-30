p = [
        125, 121, 117, 113, 109, 105, 101, 97, 126, 122, 118, 114, 110, 106, 102, 98,
        127, 123, 119, 115, 111, 107, 103, 99, 124, 120, 116, 112, 108, 104, 100, 96,

        94, 90, 86, 82, 78, 74, 70, 66, 95, 91, 87, 83, 79, 75, 71, 67,
        92, 88, 84, 80, 76, 72, 68, 64, 93, 89, 85, 81, 77, 73, 69, 65,

        63, 59, 55, 51, 47, 43, 39, 35, 60, 56, 52, 48, 44, 40, 36, 32,
        61, 57, 53, 49, 45, 41, 37, 33, 62, 58, 54, 50, 46, 42, 38, 34,

        28, 24, 20, 16, 12, 8, 4, 0, 29, 25, 21, 17, 13, 9, 5, 1,
        30, 26, 22, 18, 14, 10, 6, 2, 31, 27, 23, 19, 15, 11, 7, 3
]

s = [0x1, 0xA, 0x4, 0xC, 0x6, 0xF, 0x3, 0x9, 0x2, 0xD, 0xB, 0x7, 0x5, 0x0, 0x8, 0xE]

rc = [
  0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3E, 0x3D, 0x3B, 0x37, 0x2F, 0x1E, 0x3C, 0x39, 0x33, 0x27, 0x0E,
  0x1D, 0x3A, 0x35, 0x2B, 0x16, 0x2C, 0x18, 0x30, 0x21, 0x02, 0x05, 0x0B, 0x17, 0x2E, 0x1C, 0x38,
  0x31, 0x23, 0x06, 0x0D, 0x1B, 0x36, 0x2D, 0x1A, 0x34, 0x29, 0x12, 0x24, 0x08, 0x11, 0x22, 0x04
]

def ibin(x, n): return int(''.join(x), 2)
def fbin(x, n): return '{:0{}X}'.format(int(''.join(x), 2), n//4)
def tbin(x, n): return list('{:0{}b}'.format(x, n))

def swp(x, a, b):
    t = x[a]
    x[a] = x[b]
    x[b] = t
    return x

def per(x, r=1):
    for _ in range(r):
        px = [0]*128
        for i in range(128): px[127-i] = x[::-1][p[::-1][i]]
        x = px
    return x

def sch(k, rounds=1):
    for _ in range(rounds):
        w0 = k[0:16]
        w1 = k[16:32]
        w2 = k[32:48]
        w3 = k[48:64]
        w4 = k[64:80]
        w5 = k[80:96]
        w6 = k[96:112]
        w7 = k[112:128]
        
        w6r = w6[14:16] + w6[0:14]
        w7r = w7[4:16] + w7[0:4]
        rk = w2 + w3 + w6 + w7
        k = w6r + w7r + w0 + w1 + w2 + w3 + w4 + w5
    
    return rk

def gift_key(inp, rounds=1):
    x = ['-' for _ in range(128)]
    keys = []
    
    for r in range(rounds):
        rk = []
        for i in range(0, 32, 1):
            if i >= 8 and i < 24 and r > 0:
                rk += x[0:4]
            
            # Rotate state
            if r > 0 and i >= 8 and i <= 23:
                x = swp(x, 0, 64)
                x = swp(x, 1, 65)
                x = swp(x, 2, 66)
                x = swp(x, 3, 67)
        
            # Swap precedence
            if r > 0 and i >= 24 and i < 32:
                x = swp(x, 0, 32)
                x = swp(x, 1, 33)
                x = swp(x, 2, 34)
                x = swp(x, 3, 35)

            # Rotate k6
            if r > 1 and i >= 8 and i < 11:
                x = swp(x, 96, 100)
                x = swp(x, 97, 101)
                x = swp(x, 98, 102)
                x = swp(x, 99, 103)
            if r > 1 and i >= 11 and i < 13:
                x = swp(x, 84, 92)
                x = swp(x, 85, 93)
                x = swp(x, 86, 94)
                x = swp(x, 87, 95)
            if r > 1 and i >= 13 and i < 17:
                x = swp(x, 76, 78)
                x = swp(x, 77, 79)
                x = swp(x, 78, 80)
                x = swp(x, 79, 81)
            if r > 1 and i == 17:
                x = swp(x, 74, 76)
                x = swp(x, 75, 77)

            # Rotate k7
            if r > 1 and i >= 12 and i < 15:
                x = swp(x, 96, 100)
                x = swp(x, 97, 101)
                x = swp(x, 98, 102)
                x = swp(x, 99, 103)

            if r == 0: x = x[4:128] + inp[0+4*i:4+4*i]
            else: x = x[4:128] + x[0:4] 
          
        if r > 0: keys.append(rk)

    return keys

def gift_rnd(inp, keys, rounds=1):
    x = ['-' for _ in range(128)]
    
    for r in range(rounds):
        for i in range(0, 32, 1):

            if r == 0: nib = inp[0+4*i:4+4*i]
            else: nib = x[0:4]
            # if r > 0: print(r, i, fbin(x, 128))

            if i >= 24:
                s0 = tbin(s[ibin(nib[0]+x[96]+x[64]+x[32], 4)], 4)
                nib[0] = s0[0]; x[96] = s0[1]; x[64] = s0[2]; x[32] = s0[3]
                
                s0 = tbin(s[ibin(nib[1]+x[97]+x[65]+x[33], 4)], 4)
                nib[1] = s0[0]; x[97] = s0[1]; x[65] = s0[2]; x[33] = s0[3]
                
                s0 = tbin(s[ibin(nib[2]+x[98]+x[66]+x[34], 4)], 4)
                nib[2] = s0[0]; x[98] = s0[1]; x[66] = s0[2]; x[34] = s0[3]
                
                s0 = tbin(s[ibin(nib[3]+x[99]+x[67]+x[35], 4)], 4)
                nib[3] = s0[0]; x[99] = s0[1]; x[67] = s0[2]; x[35] = s0[3]
                
            if i == 31:
                # print('sub', fbin(x[4:128] + nib, 128))
                x = per(x[4:128] + nib)
                # print('per', fbin(x, 128))
                x = tbin(int(fbin(x, 128), 16) ^ (rc[r] | 1 << 31), 128)
                # print('rco', fbin(x, 128))
                x = tbin(int(fbin(x, 128), 16) ^ (int(fbin(keys[r], 64), 16) << 32), 128)
                # print('key', fbin(x, 128))
            else:
                x = x[4:128] + nib

    return x

key_orig = tbin(0x000102030405060708090A0B0C0D0E0F, 128)
key_swap = tbin(0x000102030C0D0E0F0405060708090A0B, 128)
plain    = tbin(0x000102030405060708090A0B0C0D0E0F, 128)

keys = gift_key(key_swap, 42)
ct = gift_rnd(plain, keys, 40)
print(fbin(ct, 128))
