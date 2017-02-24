CC=yosys
CFLAGS=-p "synth_ice40 -abc2  -blif outputs/test.blif" -ql outputs/test.log -o outputs/test_syn.v
# CFLAGS=-p "prep; show -stretch -prefix count -format dot"

all_test: setup
	iverilog -o outputs/proc_test.out \
		src/test_lc4_processor_tb.v \
		src/lc4_processor.v src/Nbit_reg.v src/lc4_alu.v \
		src/lc4_regfile.v src/lc4_decoder.v \
		src/include/set_testcase.v \
		src/include/bram.v src/include/memory.v \
		src/include/delay_eight_cycles.v \
		src/include/one_pulse.v \
		src/include/clock_util.v
	./outputs/proc_test.out

all: setup
	$(CC) $(CFLAGS) src/single.v src/register.v src/alu.v \
		src/regfile.v src/decoder.v \
		src/system.v \
		src/include/bram.v src/include/memory.v \
		src/include/delay_eight_cycles.v \
		src/include/one_pulse.v \
		src/include/clock_util.v
		# src/cpu.pcf
		#src/include/clkdiv.v \
		#src/include/clkgen.v
	sleep 1
	arachne-pnr outputs/test.blif -o outputs/test.asc -d 8k -p src/cpu.pcf \
		2>&1 | grep -e 'LCs' -e 'BRAM' -e 'LUT'

single: setup
	$(CC) $(CFLAGS) src/single.v src/register.v src/alu.v \
		src/regfile.v src/decoder.v \
		src/include/bram.v src/include/memory.v \
		src/include/delay_eight_cycles.v \
		src/include/one_pulse.v \
		src/include/clock_util.v
		# src/cpu.pcf
		#src/include/clkdiv.v \
		#src/include/clkgen.v
	sleep 1
	arachne-pnr outputs/test.blif -o outputs/test.asc -d 8k \
		2>&1 | grep -e 'LCs' -e 'BRAM' -e 'LUT'


alu: setup
	$(CC) $(CFLAGS) src/lc4_alu.v
	sleep 1
	arachne-pnr outputs/test.blif -o outputs/test.txt -d 8k

setup:
	rm -rf outputs
	mkdir -p outputs

serial_to_parallel: setup
	iverilog -o outputs/serial_to_prallel_tb.out src/serial_to_parallel.v src/serial_to_parallel_tb.v src/bram.v src/mon_exp.v src/mon_prod.v src/parallel_to_serial.v
	./outputs/serial_to_prallel_tb.out

serial_to_parallel_32: setup
	iverilog -o outputs/serial_to_prallel_tb.out src/serial_to_parallel.v src/serial_to_parallel_32_tb.v src/bram.v src/mon_exp.v src/mon_prod.v src/parallel_to_serial.v
	./outputs/serial_to_prallel_tb.out



parallel_to_serial: setup
	iverilog -o outputs/parallel_to_serial_tb.out src/parallel_to_serial.v src/parallel_to_serial_tb.v
	outputs/parallel_to_serial_tb.out

shift_add_mult5: setup
	iverilog -o outputs/shift_add_mult4_tb.out src/shift_add_mult4.v src/shift_add_mult4_tb.v
	outputs/shift_add_mult4_tb.out

shift_add_mult4_lut: setup
	$(CC) $(CFLAGS) src/shift_add_mult4.v
	rm ./outputs/test.blif

mon_prod: setup setup
	rm -f outputs/mon_prod_tb.out
	iverilog -o outputs/mon_prod_tb.out src/mon_prod.v src/mon_prod_tb.v src/bram.v
	outputs/mon_prod_tb.out

mon_prod_lut: setup
	$(CC) $(CFLAGS) src/mon_prod.v
	sleep 1
	arachne-pnr outputs/test.blif -o outputs/test.txt -d 8k

mon_prod_sv_lut: setup
	$(CC) $(CFLAGS) src/mon_prod_sv.v
	sleep 1
	arachne-pnr outputs/test.blif -o outputs/test.txt -d 8k

mon_exp: setup
	rm -f outputs/mon_exp_tb.out
	iverilog -o outputs/mon_exp_tb.out src/mon_prod.v src/mon_exp.v src/mon_exp_tb.v src/bram.v
	outputs/mon_exp_tb.out

mon_exp_lut: setup
	$(CC) $(CFLAGS) src/mon_exp.v src/mon_prod.v
	arachne-pnr outputs/test.blif -o outputs/test.txt -d 8k
	rm -f outputs/test.blif outputs/test.txt

bram_lut: setup
	$(CC) $(CFLAGS) src/bram.v
	sleep 1
	arachne-pnr outputs/test.blif -o outputs/test.txt -d 8k
	rm -f outputs/test.blif outputs/test.txt

top_lut: setup setup
	$(CC) $(CFLAGS) src/mon_exp_top.v src/mon_exp.v src/mon_prod.v src/bram.v
	arachne-pnr outputs/test.blif -o outputs/test.txt -d 8k
	rm -f outputs/test.blif outputs/test.txt

and_add_lut: setup
	$(CC) $(CFLAGS) src/and_add.v
	arachne-pnr outputs/test.blif -o outputs/test.txt -d 8k
#	rm -f outputs/test.blif outputs/test.txt
#
uart_top: setup
	$(CC) $(CFLAGS) src/uart_test.v src/serial_to_parallel.v src/parallel_to_serial.v src/bram.v src/mem_test.v
	arachne-pnr outputs/test.blif -o outputs/test.asc -d 8k -p src/uart_test.pcf


led_upload: setup
	$(CC) $(CFLAGS) src/led_test.v
	arachne-pnr outputs/test.blif -o outputs/test.asc -d 8k -p src/EB85.pcf
	icepack outputs/test.asc outputs/test.bin
	iceprog outputs/test.bin


uart_upload: uart_top
	icepack outputs/test.asc outputs/test.bin
	iceprog outputs/test.bin
	#screen /dev/ttyUSB1
	sleep 2
	python ../RSA-Python/shand.py


rsa_place: setup
	$(CC) $(CFLAGS) src/rsa_top.v src/parallel_to_serial.v src/serial_to_parallel.v src/bram.v src/mon_exp.v src/mon_prod.v cores/osdvu/uart.v
	arachne-pnr outputs/test.blif -o outputs/test.asc -d 8k -p src/rsa_top.pcf 2>&1
	cat outputs/test.log | grep Removed
rsa_upload: rsa_place
	icepack outputs/test.asc outputs/test.bin
	iceprog outputs/test.bin
	python ../RSA-Python/shand.py

mem_place: setup
	$(CC) $(CFLAGS) src/mem_test.v src/parallel_to_serial.v src/serial_to_parallel.v src/bram.v src/mon_exp.v src/mon_prod.v cores/osdvu/uart.v
	arachne-pnr outputs/test.blif -o outputs/test.asc -d 8k -p src/rsa_top.pcf 2>&1
	cat outputs/test.log | grep Removed
mem_upload: mem_place
	icepack outputs/test.asc outputs/test.bin
	iceprog outputs/test.bin

upload:
	iceprog outputs/test.bin
	#python ../RSA-Python/shand.py
screen:
	screen /dev/ttyUSB1

