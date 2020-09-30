# AES 256 encryption/decryption using pycrypto library

import binascii
from Crypto.Cipher import AES
import random

def hex(abc):
    b = binascii.hexlify(abc)
    b = str(b, "UTF-8")
    return b

def unhex(hx):
    return binascii.unhexlify(hx)
    return str(b, "UTF-8")
    
BLOCK_SIZE = 16

k= "603DEB1015CA71BE2B73AEF0857D7781"
pt="6BC1BEE22E409F96E93D7E117393172A"

for j in range(100):
    cipher = AES.new(unhex(k))
    ct = hex(cipher.encrypt(unhex(pt)))
    print(pt)
    print(k)
    print(ct)
    tmp = k
    k = ct
    pt = tmp
