GIFT = [
 0, 33, 66,  99,     96,  1, 34, 67,    64,  97,  2, 35,    32, 65,  98,  3,
 4, 37, 70, 103,    100,  5, 38, 71,    68, 101,  6, 39,    36, 69, 102,  7,
 8, 41, 74, 107,    104,  9, 42, 75,    72, 105, 10, 43,    40, 73, 106, 11,
12, 45, 78, 111,    108, 13, 46, 79,    76, 109, 14, 47,    44, 77, 110, 15,
16, 49, 82, 115,    112, 17, 50, 83,    80, 113, 18, 51,    48, 81, 114, 19,
20, 53, 86, 119,    116, 21, 54, 87,    84, 117, 22, 55,    52, 85, 118, 23,
24, 57, 90, 123,    120, 25, 58, 91,    88, 121, 26, 59,    56, 89, 122, 27,
28, 61, 94, 127,    124, 29, 62, 95,    92, 125, 30, 63,    60, 93, 126, 31 ]

sbox = [0x1, 0xA, 0x4, 0xC, 0x6, 0xF, 0x3, 0x9, 0x2, 0xD, 0xB, 0x7, 0x5, 0x0, 0x8, 0xE]

cycles1 = [ list(range(64+1, 64+17)) + list(range(80+1, 80+17)), 
            list(range(2, 18)) + list(range(64+2, 64+18)) ]

#cycles1 = [ list(range(64+1, 64+17)),#+ list(range(96+1, 112+1)), 
#            list(range(64+1, 64+17)),#list(range(64+1, 64+17)),
#            list(range(64+2, 64+18)) ]
            
cycles2 = [ [69, 70, 71, 72] + [89, 90, 91, 92] + [109, 110, 111, 112] + [5, 6, 7, 8] + [25, 26, 27, 28] + [45, 46, 47, 48], 
            [86, 87, 88, 89] + [106, 107, 108, 109] + [22, 23, 24, 25] + [42, 43, 44, 45], 
            [103, 104, 105, 106] + [39, 40, 41, 42]]
            
cycles3 = [ [(16*j + 121-8) % 128 for j in range(8)] + [(16*j + 121) % 128 for j in range(8)] + [(16*j + 123) % 128 for j in range(8)], 
            [(16*j + 127) % 128 for j in range(8)] + [(16*j + 127 - 2) % 128 for j in range(8)],
            [(16*j + 125) % 128 for j in range(8)]  ]


swaps1 = [(32, 0), (49,33)]
swaps2 = [(64, 52), (77, 53), (90, 54)]
swaps3 = [(118, 114), (121, 113), (124, 112)]

# below, I will invert the order of applications of the permutation

# swaps1= [(x+52, y+52) for (x,y) in swaps1]
# cycles1 = [ [(x+52)%128  for x in y] for y in cycles1]
swaps1= [(x+52+4, y+52+4) for (x,y) in swaps1]
cycles1 = [ [(x+52+4)%128  for x in y] for y in cycles1]

# swaps2= [(x-39, y-39) for (x,y) in swaps2]
# cycles2 = [ [(x-39)%128  for x in y] for y in cycles2]
swaps2= [(x-39+4, y-39+4) for (x,y) in swaps2]
cycles2 = [ [(x-39+4)%128  for x in y] for y in cycles2]

# swaps3= [(x-112, y-112) for (x,y) in swaps3]
# cycles3 = [ [(x-112)%128  for x in y] for y in cycles3]
swaps3= [(x-112+4, y-112+4) for (x,y) in swaps3]
cycles3 = [ [(x-112+4)%128  for x in y] for y in cycles3]

# print(swaps1)
# print(swaps2)
# print(swaps3)
# print(cycles1)
# print(cycles2)
# print(cycles3)

def apply_permutation(X, perm):
    Z = [' '] * 128
    for i in range(128):
        Z[127-perm[i]] = X[127-i]
    return Z
    
def print_pipe(S):
    Z = list(reversed(S))
    for j in range(8):
        print(Z[16*j: 16*(j+1)])
    print()

def print_pipe2(S):
    Z = list(reversed(S))
    #print(''.join(Z))
    print(format(int(''.join(Z), 2), '0>32X'))

def substitute(S, tail):
    v = sbox[int(''.join(S[0:3][::-1] + [tail]), 2)]
    sub = list(format(v, '0>4b'))[::-1]
    S[0:3] = sub[1:4]
    S[-1] = sub[0]
    return S

    # print('======', v, sub)

def executeSwaps(S, round, count):
    disableSwaps1 = False # (round == 0 and count <= 69) or (round == 31 and count > 69)
    disableSwaps2 = False # (round == 0 and count <= 11) or (round == 31 and count > 11)
    disableSwaps3 = False # (round == 0 and count <= 8) or (round == 31 and count > 8)
    for j in range(len(swaps1)):
        if count in cycles1[j] and not disableSwaps1:
            (x, y) = swaps1[j]
            (S[x], S[y]) = (S[y], S[x])
            # print("swapping 1 round :" + str(round) + "\tcycle: " + str(count) )
    for j in range(len(swaps2)):
        if count in cycles2[j] and not disableSwaps2:
            (x, y) = swaps2[j]
            (S[x], S[y]) = (S[y], S[x])
            # print("swapping 2 round :" + str(round) + "\tcycle: " + str(count) )
    for j in range(len(swaps3)):
        if count in cycles3[j] and not disableSwaps3:
            (x, y) = swaps3[j]
            (S[x], S[y]) = (S[y], S[x])
            # print("swapping 3 round :" + str(round) + "\tcycle: " + str(count) )
    return S

def rotate_pipeline(S):
    return [S[-1]] + S[:-1]

def store_input_bit(S, bit):
    S[-1] = bit
    return S

def read_exit_bit(S):
    return S[-1]

def simulate_permutation_over_pipeline(inputbits, n):
    K = [[None] * 128 for _ in range(32)] # to store output bits from pipeline
    # S = ['___'] * 128 # keeps the contents of the pipeline
    S = ['0'] * 128 # keeps the contents of the pipeline
    for round in range(n):
        for count in range(128):
            # if count % 1 == 0:
            #     print("start " + str(round) + "\tcycle: " + str(count) + " ", end='')
            #     print_pipe2(S)
            
            S = executeSwaps(S, round, count)
            K[round][count] = read_exit_bit(S)
            
            if round == 0:
                S = store_input_bit(S, inputbits[count])
            else:
                S = store_input_bit(S, K[round][count])
            
            if count % 4 == 3:
                S = substitute(S, S[-1])
                
            S = rotate_pipeline(S)
            if count % 1 == 0:
                print("end " + str(round) + "\tcycle: " + str(count) + " ", end='')
                print_pipe2(S)
    return K[1:]

x = "000102030405060708090A0B0C0D0E0F"
y = []
for d in x:
    # l = format(int(d, 16), '0<4b')
    l ='{:04b}'.format(int(d, 16))
    #y += list(reversed(l))
    y += list(l)

print(y)
#x = "F0E0D0C0B0A090807060504030201000"
# inputbits = list(format(int(x, 16), '0>128b'))

inputbits = y
result = apply_permutation(inputbits, GIFT)

# stateletters = [chr(y+65) for y in range(26)] + [chr(y+97) for y in range(6)]
# inputbits = [[str(hex(x))  for x in range(127, -1, -1)] for y in stateletters]
#results = [apply_permutation(x, GIFT) for x in inputbits]
# results = results[:-1] # the last 64 bits are not used, they are placeholder

K = simulate_permutation_over_pipeline(inputbits, 1)

# print(swaps1)
# print(swaps2)
# print(swaps3)
# print(cycles1)
# print(cycles2)
# print(cycles3)

# print("An example output from the first round of the pipeline:")
# print_pipe(K[0])
# print("Expected result: ")
# print_pipe(results[0])

# if K[0] == results[0]:
#     print(str(len(results)) + "*128 bits are permuted correctly")
# else:
#     print("there is an issue")
