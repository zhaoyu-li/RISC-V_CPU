TOOL_CHAIN = /opt/riscv/bin
CROSS_COMPILE = $(TOOL_CHAIN)/riscv32-unknown-elf-

# $< means the first arg, and $@ means our 'MAKE' target
%.o: %.s
	$(CROSS_COMPILE)as $< -o $@ -march=rv32i

%.om: %.o
	$(CROSS_COMPILE)ld $< -o $@

# .data can be examined directly
%.data: %.om
	# $(CROSS_COMPILE)objcopy -O verilog $< $@
	$(CROSS_COMPILE)objcopy -O verilog $< test.data
	$(CROSS_COMPILE)objdump -M no-aliases -D $< > test.dump

# .bin is used by FPGA controller
%.bin: %.om
	$(CROSS_COMPILE)objcopy -O binary $< $@

clean:
	rm -f *.bin *.om *.o *.bin *.data
