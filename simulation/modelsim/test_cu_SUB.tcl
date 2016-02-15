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

###############################################################################
#  TEST SUB INSTRUCTION
###############################################################################
proc test_SUB {} {

	dict set fetch state 			FETCH
	dict set fetch pc_write 		1
	dict set fetch inst_data_sel 	0
	dict set fetch mem_read 		1
	dict set fetch mem_write 		0
	dict set fetch ir_write			1
	dict set fetch rd_sel			x
	dict set fetch rd_data_sel		x
	dict set fetch rd_write_en		0
	dict set fetch alu_op_a_sel		0
	dict set fetch alu_op_b_sel		00
	dict set fetch alu_arith_fn		0
	dict set fetch alu_logic_fn		x
	dict set fetch alu_fn			10
	dict set fetch pc_src_sel		11
	dict set fetch jmp_addr_sel		x

	dict set decode state 			DECODE
	dict set decode pc_write 		x
	dict set decode inst_data_sel 	x
	dict set decode mem_read 		0
	dict set decode mem_write 		0
	dict set decode ir_write		0
	dict set decode rd_sel			x
	dict set decode rd_data_sel		x
	dict set decode rd_write_en		0
	dict set decode alu_op_a_sel	0
	dict set decode alu_op_b_sel	11
	dict set decode alu_arith_fn	0
	dict set decode alu_logic_fn	x
	dict set decode alu_fn			10
	dict set decode pc_src_sel		x
	dict set decode jmp_addr_sel	x

	dict set alu_1 state 			ALU_1
	dict set alu_1 pc_write 		x
	dict set alu_1 inst_data_sel 	x
	dict set alu_1 mem_read 		0
	dict set alu_1 mem_write 		0
	dict set alu_1 ir_write			0
	dict set alu_1 rd_sel			x
	dict set alu_1 rd_data_sel		x
	dict set alu_1 rd_write_en		0
	dict set alu_1 alu_op_a_sel		1
	dict set alu_1 alu_op_b_sel		01
	dict set alu_1 alu_arith_fn		1
	dict set alu_1 alu_logic_fn		x
	dict set alu_1 alu_fn			10
	dict set alu_1 pc_src_sel		x
	dict set alu_1 jmp_addr_sel		x

	dict set alu_2 state 			ALU_2
	dict set alu_2 pc_write 		x
	dict set alu_2 inst_data_sel 	x
	dict set alu_2 mem_read 		0
	dict set alu_2 mem_write 		0
	dict set alu_2 ir_write			0
	dict set alu_2 rd_sel			01
	dict set alu_2 rd_data_sel		1
	dict set alu_2 rd_write_en		1
	dict set alu_2 alu_op_a_sel		x
	dict set alu_2 alu_op_b_sel		x
	dict set alu_2 alu_arith_fn		x
	dict set alu_2 alu_logic_fn		x
	dict set alu_2 alu_fn			x
	dict set alu_2 pc_src_sel		x
	dict set alu_2 jmp_addr_sel		x


	# RUN INSTRUCTION
	# --------------------------------------------------
	force -freeze clk 1 0, 0 5 ms -repeat 10 ms
	force -freeze rst 0 0, 1 1 ms

	force -freeze op 000000 0 ms
	force -freeze fn 100010 0 ms

	run 50 ms
	wave zoom full

	# VERIFY CONTROL SIGNALS
	# --------------------------------------------------
	verify_signals 0 	$fetch
	verify_signals 10 	$decode
	verify_signals 20 	$alu_1
	verify_signals 30 	$alu_2
	verify_signals 40 	$fetch
}

proc verify_signals {time signals} {

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

	echo "\n=========================================="
	echo "[dict get $signals state] STATE $time ms"
	echo "=========================================="
	echo "SIGNAL:\t\t\tEXP\tREAL\tRES"
	echo "------------------------------------------"

	verify_signal state [dict get $signals state] $state
	verify_signal pc_write [dict get $signals pc_write] $pc_write
	verify_signal inst_data_sel [dict get $signals inst_data_sel] $inst_data_sel
	verify_signal mem_read [dict get $signals mem_read] $mem_read
	verify_signal mem_write [dict get $signals mem_write] $mem_write
	verify_signal ir_write [dict get $signals ir_write] $ir_write
	verify_signal rd_sel [dict get $signals rd_sel] $rd_sel
	verify_signal rd_data_sel [dict get $signals rd_data_sel] $rd_data_sel
	verify_signal rd_write_en [dict get $signals rd_write_en] $rd_write_en
	verify_signal alu_op_a_sel [dict get $signals alu_op_a_sel] $alu_op_a_sel
	verify_signal alu_op_b_sel [dict get $signals alu_op_b_sel] $alu_op_b_sel
	verify_signal alu_arith_fn [dict get $signals alu_arith_fn] $alu_arith_fn
	verify_signal alu_logic_fn [dict get $signals alu_logic_fn] $alu_logic_fn
	verify_signal alu_fn [dict get $signals alu_fn] $alu_fn
	verify_signal pc_src_sel [dict get $signals pc_src_sel] $pc_src_sel
	verify_signal jmp_addr_sel [dict get $signals jmp_addr_sel] $jmp_addr_sel
}

proc verify_signal {name expected real} {
	if {$expected != "x"} {
		if {$expected == $real} {
			echo "$name:\t\t\t$expected\t$real\tPASS"
		} else {
			echo "$name:\t\t\t$expected\t$real\tFAIL"
		}
	} else {
		echo "$name:\t\t\t$expected\t$real\tXXXX"
	}
}
