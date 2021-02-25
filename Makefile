
bitstream: top.bit

top.bit: src/*
	vivado -mode tcl -nolog -nojournal -source create_bitstream.tcl

program_fpga: top.bit
	vivado -mode tcl -nolog -nojournal -source program_fpga.tcl

clean:
	rm -f top.bit *vivado*log *vivado*jou *webtalk*
