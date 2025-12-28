@echo off

ghdl -a Eq05-reg16bits.vhd
ghdl -a Eq05-RegFile.vhd
ghdl -a Eq05-RegFile_tb.vhd

ghdl -e Eq05-RegFile_tb

ghdl -r Eq05-RegFile_tb --wave=Eq05-RegFile.ghw --stop-time=200ns

gtkwave Eq05-RegFile.ghw Eq05-RegFile.gtkw
