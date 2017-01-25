#!/bin/bash

PENNSIM_PATH="../../../../../jlc4sim/PennSim.jar"

python lc4_rand_test.py

rm -rf test_all.hex test_alu.hex test_br.hex test_mem.hex test_ld_br.hex 
rm -rf test_all.trace test_alu.trace test_br.trace test_mem.trace test_ld_br.trace 

echo Running script to generate test trace and hex files...

java -enableassertions -jar $PENNSIM_PATH -t -s test.script
