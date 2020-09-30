sh rm -rf work/*
remove_design -all

set basePath "../../src"
set commonfiles    "${basePath}/lfsr.vhd\
                    ${basePath}/sbox.vhd\
                    ${basePath}/mix_col_slice.vhd\
                    ${basePath}/state_pipeline.vhd\
                    ${basePath}/key_pipeline1.vhd\
                    ${basePath}/key_pipeline2.vhd\
                    ${basePath}/controller.vhd\
                    ${basePath}/rho.vhd\
                    ${basePath}/lfsr24.vhd\
                    ${basePath}/aead_controller.vhd\
                    ${basePath}/aead.vhd"

                    
define_design_lib work -path ./work

analyze -library work -format vhdl $commonfiles


elaborate aead -architecture behav -library work

create_clock -name "clk" -period 100 -waveform { 0 50  } { clk  }

#compile
compile_ultra

uplevel #0 { report_timing -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group > timing.txt}

uplevel #0 { report_area -hierarchy > area.txt}
 
write -hierarchy -format verilog -output syn.v 

write_sdf syn.sdf

write_file -hierarchy -output design_vision_session.ddc

exit 0