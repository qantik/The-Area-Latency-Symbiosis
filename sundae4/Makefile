SRC_PATH    = src
BUILD_DIR   = build
TEST_DIR    = test_vectors
VHDL_SRCS   = \
				$(SRC_PATH)/sbox.vhd \
				$(SRC_PATH)/lfsr.vhd \
				$(SRC_PATH)/key.vhd \
				$(SRC_PATH)/state.vhd \
				$(SRC_PATH)/sundae.vhd \
				$(SRC_PATH)/aead_tb.vhd

TB_MODULE   = aead_tb

WORKLIB     = $(BUILD_DIR)/work-obj93.cf
WAVEFILE    = wavefile.vcd

all: verify

$(BUILD_DIR): test_generator
	mkdir -p $(BUILD_DIR)
	cp $(TEST_DIR)/Testinput.txt $(TEST_DIR)/Testoutput.txt $(BUILD_DIR)/

$(WORKLIB): $(VHDL_SRCS) $(BUILD_DIR)
	ghdl -a --ieee=synopsys -fexplicit --workdir=$(BUILD_DIR) $(VHDL_SRCS)

elaborate: $(WORKLIB) $(BUILD_DIR)
	ghdl -e --ieee=synopsys -fexplicit --workdir=$(BUILD_DIR) $(TB_MODULE)

$(WAVEFILE): elaborate $(BUILD_DIR)
	cd $(BUILD_DIR) && ghdl -r --ieee=synopsys -fexplicit $(TB_MODULE) --vcd=$(WAVEFILE)

analyse: $(WORKLIB)

verify: $(WAVEFILE)
	cd $(BUILD_DIR) && ../verify.sh

test_generator:
	cd $(TEST_DIR) && gcc -c gift128.c && gcc -c sundae.c && gcc -o main.exe main.c gift128.o sundae.o && ./main.exe 1>/dev/null

clean:
	rm -f $(WAVEFILE) $(WORKLIB) 
	rm -f $(TEST_DIR)/*.o $(TEST_DIR)/main.exe $(TEST_DIR)/Testinput.txt $(TEST_DIR)/Testoutput.txt
	rm -rf $(BUILD_DIR) 	
	
.PHONY: elaborate analyze verify test_generator clean
