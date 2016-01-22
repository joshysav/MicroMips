proc run_test {} {	
	restart -force -nowave
	
	#Add signals to wave
	add wave -color blue -logic clk
	add wave -color blue -radix unsigned rs_sel
	add wave -color blue -radix hexadecimal rs_data
	add wave -color blue -radix unsigned rt_sel
	add wave -color blue -radix hexadecimal rt_data
	add wave -color orange -logic write_en
	add wave -color blue -radix unsigned rd_sel
	add wave -color blue -radix hexadecimal rd_data
	add wave -color blue -radix hexadecimal register_f_s
	
	# Start clock
	force -freeze /register_file/clk 1 0, 0 5ms -repeat 10ms
		
	array set registers {
		0	0
		1	0
		2	0
		3	0
		4	0
		5	0
		6	0
		7	0
		8	0
		9	0
		10	0
		11	0
		12	0
		13	0
		14	0
		15	0
		16	0
		17	0
		18	0
		19	0
		20	0
		21	0
		22	0
		23	0
		24	0
		25	0
		26	0
		27	0
		28	0
		29	0
		30	0
		31	0
	}
	
	set time 0
	
	# ---------------------
	# REPEAT 10 times
	# ---------------------
	for {set i 0} {$i < 10 } {incr i} {
		
		# Select random destination register
		set dest_reg [expr {int(rand() * 4)}]
		# Select random source registers
		set src_reg_s [expr {int(rand() * 4)}]
		set src_reg_t [expr {int(rand() * 4)}]
		# Random data to write
		set data [format %x [expr {int(rand() * 0xFFFFFFFF)}]]
		# Write or not
		set wr_en [expr {int(rand() * 2)}]
			
		force -freeze /register_file/write_en $wr_en $time ms
		force -freeze /register_file/rd_sel 10#$dest_reg $time ms 
		force -freeze /register_file/rd_data 16#$data $time ms
		force -freeze /register_file/rs_sel 10#$src_reg_s $time ms
		force -freeze /register_file/rt_sel 10#$src_reg_t $time ms
				
		run 10ms
		
		# Examine src register number and output value
		set reg_s_index [examine -time $time ms -decimal /register_file/rs_sel]
		set reg_s_out [examine -time $time ms -decimal /register_file/rs_data]
		
		# Compare output with array
		echo "====================================="
		echo "TIME: 			$time"
		echo "REG_S SEL: 			$reg_s_index"
		echo "OUT VALUE:			$reg_s_out"
		echo "MUST BE:			$registers($reg_s_index)"
		if {$registers($reg_s_index) == $reg_s_out} {
			echo "	------------------------"
			echo "	PASS"
			echo "	------------------------"
		} else {
			echo "fail"
		}
		
		if {$wr_en == 1} {
			set registers($dest_reg) $data
			echo "Write to register: $dest_reg value:$data"
		}
		
		set time [expr $time + 10]
		
	}
	
	foreach {n reg} [array get registers] {

    echo "$n -> $reg"
}
	
	wave zoom full
}