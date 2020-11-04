For functional verification, we assume that you already have modelsim installed. (Although we have not tested with other tools, in our code there is nothing specific to modelsim so it should work fine with other tools too.)

Running the functional correctness would go as follows:
1) Pick a circuit to test (e.g. choose skinnyz1).
2) Create a modelsim project.
3) Import all files of a particular implementation (under skinnyz1/src).
4) Copy the test vector files (under skinnyz1/test_vectors) to the working directory of the current modelsim project.
5) Run the simulation (generally 1s is long enough).
6) The testbench encounter a "failure" and outputs ">>> OK <<<" (this is used as the stop condition for the testbench and indicates that the test is passed).

Note: skinnyz1/scripts are used only for Synopsys tools, for post-synthesis and verification.





For post-synthesis verification and extraction of measurements, we assume that you already have the tools and the technology libraries (e.g. STM 90 nm, TSMC 90 nm etc.) installed. You should also be familiar with the tools in order to follow the described steps. 

Then it goes as follows:
1) Pick a circuit to test (e.g. choose skinnyz1)
2) Use compile.tcl to construct a hierarchy of files. Namely, this script assume that the source files are located at "../../src". You may either modify the script file or consturct a folder hierarchy to match the script.
3) Assuming that the tools and the libraries are correctly set up, "dc_shell -f compile.tcl" should synthesize the circuit.
4) Run the post-synthesis simulation. In our case, what we did is:
    i) vlogan <library_files.v>  # these are the .v source files from the library itself
    ii) vlogan syn.v # this is the synthesized circuit as Verilog file
    iii) vcs -full64 -debug -sdf typ:testbench/mut:syn.sdf testbench +neg_tchk +sdfverbose
    iv) ./simv -ucli -include ../scripts/saif.cmd # this runs the simulation according to configuration from saif.cmd
5) "dc_shell -f power.tcl" should extact the power measurements
6) The relevant measurements files are area.txt, powercon_lp.txt, powerhier_lp.txt and timing.txt.

Again, for the post-synthesis part, we assume familiarity with the Synopsys tools. The scripts are only given to describe the configurations.
