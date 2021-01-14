SRC_PATH    = src
BUILD_DIR   = build
VHDL_SRCS   = \
				$(SRC_PATH)/mix_col_slice.vhd \
				$(SRC_PATH)/lfsr.vhd \
				$(SRC_PATH)/sbox.vhd \
				$(SRC_PATH)/controller.vhd \
				$(SRC_PATH)/key_pipeline1.vhd \
				$(SRC_PATH)/state_pipeline.vhd \
				$(SRC_PATH)/skinny.vhd \
				$(SRC_PATH)/testbench.vhd

TB_MODULE   = testbench

WORKLIB     = $(BUILD_DIR)/work-obj93.cf
WAVEFILE    = wavefile.vcd

all: verify

$(BUILD_DIR): test_generator
	mkdir -p $(BUILD_DIR)
	cp test_vectors/Testinput.txt test_vectors/Testoutput.txt $(BUILD_DIR)/

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
	cd test_vectors && gcc skinny_modified.c -o test_gen.exe  && ./test_gen.exe 

clean:
	rm -f $(WAVEFILE) $(WORKLIB) test_vectors/test_gen.exe test_vectors/Testinput.txt test_vectors/Testoutput.txt
	rm -rf $(BUILD_DIR) 	
	
.PHONY: elaborate analyze verify test_generator clean
