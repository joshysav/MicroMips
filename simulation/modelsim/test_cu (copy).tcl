# CLEAR WAVEFORM
restart -force -nowave

# ADD SIGNALS
add wave rst
add wave clk
add wave op
add wave fn
add wave alu_zero
add wave -color orange state

add wave pc_write
add wave inst_data_sel
add wave mem_read
add wave mem_write
add wave ir_write
add wave rd_sel
add wave rd_data_sel
add wave rd_write_en
add wave alu_op_a_sel
add wave alu_op_b_sel
add wave alu_arith_fn
add wave alu_logic_fn
add wave alu_fn
add wave pc_src_sel
add wave jmp_addr_sel

set time 1

# =======================================================================
# RUN TEST FOR CONTROL SIGNALS
# =======================================================================
proc test_control_signals {} {
	force -freeze clk 1 0, 0 5 ms -repeat 10 ms
	force -freeze rst 0 0, 1 1 ms

	lui
	lui

	wave zoom full
}

# =======================================================================
# RUN LUI
# =======================================================================
proc lui {} {
	global set time 1

	force -freeze op 001111

	echo ""
	echo "======================================="
	echo " LUI "
	echo "======================================="

	# FETCH
	run 10 ms
	examine_fetch
	set time [expr $time + 10]

	# DECODE
	run 10ms
	examine_decode
	set time [expr $time + 10]

	# ALU_1
	run 10ms
	set time [expr $time + 10]

	# ALU_2
	run 10ms
	set time [expr $time + 10]
}

# =============================================================================
# EXAMINE FETCH STATE
# =============================================================================
proc examine_fetch {} {
	global set time

	echo "\nFETCH STATE $time ms"
	echo "-----------------------"

	set state [examine -time $time ms -ascii /control_unit/state]
	set pc_write [examine -time $time ms -binary /control_unit/pc_write]
	set inst_data_sel [examine -time $time ms -binary /control_unit/inst_data_sel]
	set mem_read [examine -time $time ms -binary /control_unit/mem_read]
	set mem_write [examine -time $time ms -binary /control_unit/mem_write]
	set ir_write [examine -time $time ms -binary /control_unit/ir_write]
	set rd_sel [examine -time $time ms -binary /control_unit/rd_sel]
	set rd_data_sel [examine -time $time ms -binary /control_unit/rd_data_sel]
	set rd_write_en [examine -time $time ms -binary /control_unit/rd_write_en]
	set alu_op_a_sel [examine -time $time ms -binary /control_unit/alu_op_a_sel]
	set alu_op_b_sel [examine -time $time ms -binary /control_unit/alu_op_b_sel]
	set alu_arith_fn [examine -time $time ms -binary /control_unit/alu_arith_fn]
	set alu_logic_fn [examine -time $time ms -binary /control_unit/alu_logic_fn]
	set alu_fn [examine -time $time ms -binary /control_unit/alu_fn]
	set pc_src_sel [examine -time $time ms -binary /control_unit/pc_src_sel]
	set jmp_addr_sel [examine -time $time ms -binary /control_unit/jmp_addr_sel]

	# -- STATE
	if {$state == "FETCH"} {
		echo "State:\t\t\t$state\tPASS"
	} else {
		echo "State:\t\t\t$state\tFAIL"
	}
	# -- PC_WRITE
	if {$pc_write == "1"} {
		echo "pc_write:\t\t\t$pc_write\tPASS"
	} else {
		echo "pc_write:\t\t\t$pc_write\tFAIL"
	}
	# -- INST_DATA_SEL
	if {$inst_data_sel == "0"} {
		echo "inst_data_sel:\t\t\t$inst_data_sel\tPASS"
	} else {
		echo "inst_data_sel:\t\t\t$inst_data_sel\tFAIL"
	}
	# -- MEM_READ
	if {$mem_read == "1"} {
		echo "mem_read:\t\t\t$mem_read\tPASS"
	} else {
		echo "mem_read:\t\t\t$mem_read\tFAIL"
	}
	# -- MEM_WRITE
	if {$mem_write == "0"} {
		echo "mem_write:\t\t\t$mem_write\tPASS"
	} else {
		echo "mem_write:\t\t\t$mem_write\tFAIL"
	}
	# -- IR_WRITE
	if {$ir_write == "1"} {
		echo "ir_write:\t\t\t$ir_write\tPASS"
	}	else {
		echo "$ir_write:\t\t\t$ir_write\tFAIL"
	}
	# -- RD_SEL
	if {$rd_sel == "0"} {
		echo "rd_sel:\t\t\t$rd_sel\tDONT CARE"
	} else {
		echo "rd_sel:\t\t\t$rd_sel\tDONT CARE"
	}
	# -- RD_DATA_SEL
	if {$rd_data_sel == "0"} {
		echo "rd_data_sel:\t\t\t$rd_data_sel\tDONT CARE"
	} else {
		echo "rd_data_sel:\t\t\t$rd_data_sel\tDONT CARE"
	}
	# -- RD_WRITE_EN
	if {$rd_write_en == "0"} {
		echo "rd_write_en:\t\t\t$rd_write_en\tPASS"
	} else {
		echo "rd_write_en:\t\t\t$rd_write_en\tFAIL"
	}
	# -- ALU_OP_A_SEL
	if {$alu_op_a_sel == "0"} {
		echo "alu_op_a_sel:\t\t\t$alu_op_a_sel\tPASS"
	} else {
		echo "alu_op_a_sel:\t\t\t$alu_op_a_sel\tFAIL"
	}
	# -- ALU_OP_B_SEL
	if {$alu_op_b_sel == "00"} {
		echo "alu_op_b_sel:\t\t\t$alu_op_b_sel\tPASS"
	} else {
		echo "alu_op_b_sel:\t\t\t$alu_op_b_sel\tFAIL"
	}
	# -- ALU_ARITH_FN
	if {$alu_arith_fn == "0"} {
		echo "alu_arith_fn:\t\t\t$alu_arith_fn$alu_arith_fn\tPASS"
	} else {
		echo "alu_arith_fn:\t\t\t$alu_arith_fn\tFAIL"
	}
	# -- ALU_LOGIC_FN
	if {$alu_logic_fn == "0"} {
		echo "alu_logic_fn:\t\t\t$alu_logic_fn\tDONT CARE"
	} else {
		echo "alu_logic_fn:\t\t\t$alu_logic_fn\tDONT CARE"
	}
	# -- ALU_FN
	if {$alu_fn == "10"} {
		echo "alu_fn:\t\t\t$alu_fn\tPASS"
	} else {
		echo "alu_fn:\t\t\t$alu_fn\tFAIL"
	}
	# -- PC_SRC_SEL
	if {$pc_src_sel == "11"} {
		echo "pc_src_sel:\t\t\t$pc_src_sel\tPASS"
	} else {
		echo "pc_src_sel:\t\t\t$pc_src_sel\tFAIL"
	}
	# -- JMP_ADDR_SEL
	if {$jmp_addr_sel == "0"} {
		echo "jmp_addr_sel:\t\t\t$jmp_addr_sel\tDONT CARE"
	} else {
		echo "jmp_addr_sel:\t\t\t$jmp_addr_sel\tDONT CARE"
	}
}

# =============================================================================
# EXAMINE DECODE STATE
# =============================================================================
proc examine_decode {} {
	global set time

	echo "\nDECODE STATE $time ms"
	echo "-----------------------"

	set state [examine -time $time ms -ascii /control_unit/state]
	set pc_write [examine -time $time ms -binary /control_unit/pc_write]
	set inst_data_sel [examine -time $time ms -binary /control_unit/inst_data_sel]
	set mem_read [examine -time $time ms -binary /control_unit/mem_read]
	set mem_write [examine -time $time ms -binary /control_unit/mem_write]
	set ir_write [examine -time $time ms -binary /control_unit/ir_write]
	set rd_sel [examine -time $time ms -binary /control_unit/rd_sel]
	set rd_data_sel [examine -time $time ms -binary /control_unit/rd_data_sel]
	set rd_write_en [examine -time $time ms -binary /control_unit/rd_write_en]
	set alu_op_a_sel [examine -time $time ms -binary /control_unit/alu_op_a_sel]
	set alu_op_b_sel [examine -time $time ms -binary /control_unit/alu_op_b_sel]
	set alu_arith_fn [examine -time $time ms -binary /control_unit/alu_arith_fn]
	set alu_logic_fn [examine -time $time ms -binary /control_unit/alu_logic_fn]
	set alu_fn [examine -time $time ms -binary /control_unit/alu_fn]
	set pc_src_sel [examine -time $time ms -binary /control_unit/pc_src_sel]
	set jmp_addr_sel [examine -time $time ms -binary /control_unit/jmp_addr_sel]

	# -- STATE
	if {$state == "DECODE"} {
		echo "State:\t\t\t$state\tPASS"
	} else {
		echo "State:\t\t\t$state\tFAIL"
	}
	# -- PC_WRITE
	if {$pc_write == "1"} {
		echo "pc_write:\t\t\t$pc_write\tDONT CARE"
	} else {
		echo "pc_write:\t\t\t$pc_write\tDONT CARE"
	}
	# -- INST_DATA_SEL
	if {$inst_data_sel == "0"} {
		echo "inst_data_sel:\t\t\t$inst_data_sel\tDONT CARE"
	} else {
		echo "inst_data_sel:\t\t\t$inst_data_sel\tDONT CARE"
	}
	# -- MEM_READ
	if {$mem_read == "0"} {
		echo "mem_read:\t\t\t$mem_read\tPASS"
	} else {
		echo "mem_read:\t\t\t$mem_read\tFAIL"
	}
	# -- MEM_WRITE
	if {$mem_write == "0"} {
		echo "mem_write:\t\t\t$mem_write\tPASS"
	} else {
		echo "mem_write:\t\t\t$mem_write\tFAIL"
	}
	# -- IR_WRITE
	if {$ir_write == "0"} {
		echo "ir_write:\t\t\t$ir_write\tPASS"
	}	else {
		echo "ir_write:\t\t\t$ir_write\tFAIL"
	}
	# -- RD_SEL
	if {$rd_sel == "0"} {
		echo "rd_sel:\t\t\t$rd_sel\tDONT CARE"
	} else {
		echo "rd_sel:\t\t\t$rd_sel\tDONT CARE"
	}
	# -- RD_DATA_SEL
	if {$rd_data_sel == "0"} {
		echo "rd_data_sel:\t\t\t$rd_data_sel\tDONT CARE"
	} else {
		echo "rd_data_sel:\t\t\t$rd_data_sel\tDONT CARE"
	}
	# -- RD_WRITE_EN
	if {$rd_write_en == "0"} {
		echo "rd_write_en:\t\t\t$rd_write_en\tPASS"
	} else {
		echo "rd_write_en:\t\t\t$rd_write_en\tFAIL"
	}
	# -- ALU_OP_A_SEL
	if {$alu_op_a_sel == "0"} {
		echo "alu_op_a_sel:\t\t\t$alu_op_a_sel\tPASS"
	} else {
		echo "alu_op_a_sel:\t\t\t$alu_op_a_sel\tFAIL"
	}
	# -- ALU_OP_B_SEL
	if {$alu_op_b_sel == "11"} {
		echo "alu_op_b_sel:\t\t\t$alu_op_b_sel\tPASS"
	} else {
		echo "alu_op_b_sel:\t\t\t$alu_op_b_sel\tFAIL"
	}
	# -- ALU_ARITH_FN
	if {$alu_arith_fn == "0"} {
		echo "alu_arith_fn:\t\t\t$alu_arith_fn\tPASS"
	} else {
		echo "alu_arith_fn:\t\t\t$alu_arith_fn\tFAIL"
	}
	# -- ALU_LOGIC_FN
	if {$alu_logic_fn == "0"} {
		echo "alu_logic_fn:\t\t\t$alu_logic_fn\tDONT CARE"
	} else {
		echo "alu_logic_fn:\t\t\t$alu_logic_fn\tDONT CARE"
	}
	# -- ALU_FN
	if {$alu_fn == "10"} {
		echo "alu_fn:\t\t\t$alu_fn\tPASS"
	} else {
		echo "alu_fn:\t\t\t$alu_fn\tFAIL"
	}
	# -- PC_SRC_SEL
	if {$pc_src_sel == "11"} {
		echo "pc_src_sel:\t\t\t$pc_src_sel\tDONT CARE"
	} else {
		echo "pc_src_sel:\t\t\t$pc_src_sel\tDONT CARE"
	}
	# -- JMP_ADDR_SEL
	if {$jmp_addr_sel == "0"} {
		echo "jmp_addr_sel:\t\t\t$jmp_addr_sel\tDONT CARE"
	} else {
		echo "jmp_addr_sel:\t\t\t$jmp_addr_sel\tDONT CARE"
	}
}

proc test_states {} {
	array set program_op {
		0 	001111		# LUI
		1 	000000		# ADD
		2 	000000		# SUB
		3 	000000		# SLT
		4 	001000		# ADDI
		5		001010		# SLTI
		6 	000000		# AND
		7 	000000		# OR
		8 	000000		# XOR
		9 	000000		# NOR
		10 	001100		# ANDI
		11 	001101		# ORI
		12	001110		# XORI
		13	100011		# LW
		14	101011		# SW
		15	000010		# J
		16	000000		# JR
		17	000001		# BLTZ
		18	000100		# BE
		19	000101		# BNE
		20	000011		# JL
		21	000000		# SYSCALL
	}

	array set program_fn {
		0 	000000		# LUI
		1 	100000		# ADD
		2 	100010		# SUB
		3 	101010		# SLT
		4 	000000		# ADDI
		5		100011		# SLTI
		6 	000000		# AND
		7 	000000		# OR
		8 	000000		# XOR
		9 	000000		# NOR
		10 	000000		# ANDI
		11 	000000		# ORI
		12	000000		# XORI
		13	000000		# LW
		14	000000		# SW
		15	000000		# J
		16	000000		# JR
		17	000000		# BLTZ
		18	000000		# BE
		19	000000		# BNE
		20	000000		# JL
		21	000000		# SYSCALL
	}


	force -freeze clk 1 0, 0 5 ms -repeat 10 ms
	force -freeze rst 0 0, 1 1 ms

	force -freeze alu_zero 0 0, 1 10 ms -repeat 20ms


	set time 0
	set index 0

	for {set i 0} {$i < 30} {incr i} {
		force -freeze op $program_op($index) $time
		force -freeze fn $program_fn($index) $time

		run 10ms

		# IF IN FETCH STATE GET NEXT INSTRUCTION
		set state [examine -time $time ms -ascii /state]
		echo "$state"
		if {$state == "ALU_2" | $state == "MEM_LD_2" | $state == "MEM_ST" | $state == "BRANCH"} {
			incr index;
		}

		set time [expr $time + 10]
	}

	save_results $time

	wave zoom full
}

proc save_results {time} {
	set filename "report_cu_signals.txt"
	set filefd [open $filename "w"]

	for {set i 0} {$i < $time} {set i [expr $i + 10]} {
		echo $i

		set state [examine -time $i ms -ascii /control_unit/state]
		set pc_write [examine -time $i ms -binary /control_unit/pc_write]
		set inst_data_sel [examine -time $i ms -binary /control_unit/inst_data_sel]
		set mem_read [examine -time $i ms -binary /control_unit/mem_read]
		set mem_write [examine -time $i ms -binary /control_unit/mem_write]
		set ir_write [examine -time $i ms -binary /control_unit/ir_write]
		set rd_sel [examine -time $i ms -binary /control_unit/rd_sel]
		set rd_data_sel [examine -time $i ms -binary /control_unit/rd_data_sel]
		set rd_write_en [examine -time $i ms -binary /control_unit/rd_write_en]
		set alu_op_a_sel [examine -time $i ms -binary /control_unit/alu_op_a_sel]
		set alu_op_b_sel [examine -time $i ms -binary /control_unit/alu_op_b_sel]
		set alu_arith_fn [examine -time $i ms -binary /control_unit/alu_arith_fn]
		set alu_logic_fn [examine -time $i ms -binary /control_unit/alu_logic_fn]
		set alu_fn [examine -time $i ms -binary /control_unit/alu_fn]
		set pc_src_sel [examine -time $i ms -binary /control_unit/pc_src_sel]
		set jmp_addr_sel [examine -time $i ms -binary /control_unit/jmp_addr_sel]

		puts $filefd "$state, $pc_write, $inst_data_sel, $mem_read"
	}

	close $filefd
}

proc test_clock {} {
	force -freeze clk 1 0, 0 5 ms -repeat 10 ms

	run 200ms
	wave zoom full
}
