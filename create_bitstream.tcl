set partNum xc7a100tcsg324-1
set topentityname top

config_webtalk -user off
read_vhdl -library usrDefLib [glob src/*.vhd]
check_syntax
#Run Synthesis
synth_design -top $topentityname   -part $partNum
source src/pins.tcl
#Implement Design
opt_design
place_design
route_design
#Generate bitstream
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force  top.bit
foreach path [glob *webtalk*] {
    file delete -force -- $path
 }
#
exit
