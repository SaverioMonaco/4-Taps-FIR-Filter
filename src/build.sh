#!/bin/bash

echo 'Compiling support vhd files:'
echo '  1/2 flipflop.vhd'
ghdl -a flipflop.vhd
echo '  2/2 flipflop_sum.vhd'
ghdl -a flipflop_sum.vhd

echo 'Compiling main vhd file:'
echo '  1/1 fir_filter.vhd'
ghdl -a fir_filter.vhd

echo 'Compiling testbench file:'
echo '  1/1 fir_filter_tb.vhd'
ghdl -a fir_filter_tb.vhd

echo 'Running main entity:'
echo '  fir_filter_4'
ghdl -r fir_filter_4

echo 'Running testbench:'
echo ' fir_filter_4_tb'
ghdl -r fir_filter_4_tb
echo 'Done'
