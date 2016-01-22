# CLEAR WAVEFORM
restart -force -nowave

# ADD SIGNALS
add wave rst
add wave clk
add wave op
add wave fn
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




# TEST CASES

# ----------------------------------
# TEST CLOCK
# ----------------------------------

proc test_states {} {
	array set program_op {
		0 	100011		# LW
		1 	100011		# LW
		2 	000000		# ADD
		3 	101011		# SW
		4 	000000		
		5	000000
		6 	000000
		7 	000000
		8 	000000
		9 	000000
		10 	000000
		11 	000000
		12	000000
		13	000000
		14	000000
		15	000000
	}	
	
	array set program_fn {
		0 	000000		# LW
		1 	000000		# LW
		2 	100000		# ADD
		3 	000000		# SW
		4 	100010		
		5 	000000
		6 	000000
		7 	000000
		8 	000000
		9 	000000
		10 	000000
		11 	000000
		12	000000
		13	000000
		14	000000
		15	000000
	}


	force -freeze clk 1 0, 0 5 ms -repeat 10 ms
	force -freeze rst 0 0, 1 1 ms
	
	set time 0
	set index 0
	
	for {set i 0} {$i < 20} {incr i} {
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
		
	
	wave zoom full
}



proc test_clock {} {
	force -freeze clk 1 0, 0 5 ms -repeat 10 ms
	
	run 200ms
	wave zoom full
}