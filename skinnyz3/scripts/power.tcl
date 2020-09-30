read_file -format ddc {./design_vision_session.ddc}

reset_switching_activity

read_saif -verbose -input full-timing.saif -instance TESTBENCH/MUT

report_power > powercon_lp.txt

report_power -hier > powerhier_lp.txt

exit 0
