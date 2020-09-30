import itertools

gift = [
    0, 33, 66,  99,     96,  1, 34, 67,    64,  97,  2, 35,    32, 65,  98,  3,
    4, 37, 70, 103,    100,  5, 38, 71,    68, 101,  6, 39,    36, 69, 102,  7,
    8, 41, 74, 107,    104,  9, 42, 75,    72, 105, 10, 43,    40, 73, 106, 11,
   12, 45, 78, 111,    108, 13, 46, 79,    76, 109, 14, 47,    44, 77, 110, 15,
   16, 49, 82, 115,    112, 17, 50, 83,    80, 113, 18, 51,    48, 81, 114, 19,
   20, 53, 86, 119,    116, 21, 54, 87,    84, 117, 22, 55,    52, 85, 118, 23,
   24, 57, 90, 123,    120, 25, 58, 91,    88, 121, 26, 59,    56, 89, 122, 27,
   28, 61, 94, 127,    124, 29, 62, 95,    92, 125, 30, 63,    60, 93, 126, 31
]

def apply_perm(x, perm):
    z = [' '] * 128
    for i in range(128):
        z[127-perm[i]] = x[127-i]
    return z

def apply_perm2(x, perm):
    z = [' '] * 128
    for i in range(128):
        z[perm[i]] = x[i]
    return z

def bits(n):
    b = [format(int(d, 16), '0>4b').split() for d in n]
    print(b)
    b = list(itertools.chain.from_iterable(b))
    print(b)
    return b + [0]*(128-len(b))
def ints(b):
    return int(''.join(str(i) for i in b), 2)

# x = 0xF0E0D0C0B0A090807060504030201000
x = "000102030405060708090A0B0C0D0E0F"
b = format(int(x, 16), '0>128b')
bp = ''.join(apply_perm2(list(b), gift))

print(b, format(int(b, 2), '0>32X'))
print(bp, format(int(bp, 2), '0>32X'))
