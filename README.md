# The Area-Latency Symbiosis

This repository contains the full source code alongside test vectors for all investigated schemes as part of the TCHES 2021 paper.

**The Area-Latency Symbiosis: Towards Improved Serial Encryption Circuits**

*Fatih Balli, Andrea Caforio and Subhadeep Banik*

*LASEC, EPFL*



**Requirements**

python3, gcc, g++, GHDL (https://github.com/ghdl/ghdl)


**Details**

Each folder given below contains a Makefile which can be used to run the testbench with GHDL. This archive does not contain the scripts that are used with Synopsys tools.


Following folders contain encryption-only block cipher implementations:  

aes             = AES-128 (bit serial)  
aes_8bit        = AES-128 (byte-serial)  
gift            = GIFT-128 (bit-serial)  
giftstar        = GIFT-128b (bit-serial) (see eprint.iacr.org/2017/622.pdf Appendix A)  
giftstar4       = GIFT-128b (nibble-serial) (see eprint.iacr.org/2017/622.pdf Appendix A)  
skinnyz1        = SKINNY-128-128 (bit-serial)  
skinnyz1_8bit   = SKINNY-128-128 (byte-serial)  
skinnyz2        = SKINNY-128-256 (bit-serial)  
skinnyz2_8bit   = SKINNY-128-256 (byte-serial)  
skinnyz3        = SKINNY-128-384 (bit-serial)  
skinnyz3_8bit   = SKINNY-128-384 (byte-serial)  

Following folders contain encryption-only authenticated encryption implementations:  

romulusN1       = Romulus-N1 (bit-serial)  
romulusN1_8bit  = Romulus-N1 (byte-serial)  
romulusN3       = Romulus-N3 (bit-serial)  
skinny-aead1    = SKINNY-AEAD M1 (bit-serial)  
skinny-aead8    = SKINNY-AEAD M1 (byte-serial)  
sundae          = SUNDAE-GIFT-96 (bit-serial)  
sundae4         = SUNDAE-GIFT-96 (nibble-serial)  


