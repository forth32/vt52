#!/bin/sh
./macro11 -o terminal.obj -l terminal.lst terminal.mac
./rt11obj2bin terminal.obj > terminal.map
srec_cat terminal.obj.bin -binary --byte-swap 2 -o terminal.mif -Memory_Initialization_File 16 -obs=2
srec_cat terminal.obj.bin -binary --byte-swap 2 -o terminal.mem -Vmem 16 -obs=2
