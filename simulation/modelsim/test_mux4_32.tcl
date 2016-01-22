proc testSelect {} {
	# ---------------------------------------------------------
	# SETUP SIGNALS
	# ---------------------------------------------------------

	restart -force -nowave
	#Add signals to wave

	add wave -color blue -radix hexadecimal a
	add wave -color blue -radix hexadecimal b
	add wave -color blue -radix hexadecimal c
	add wave -color blue -radix hexadecimal d
	add wave -color blue -logic sel
	add wave -color blue -radix hexadecimal o
	
	# ---------------------------------------------------------
	# SET START VALUES
	# ---------------------------------------------------------

	# Random values for data inputs
	set val1 [format %u [expr {int(rand() * 0xFFFFFFFF)}]]
	set val2 [format %u [expr {int(rand() * 0xFFFFFFFF)}]]
	set val3 [format %u [expr {int(rand() * 0xFFFFFFFF)}]]
	set val4 [format %u [expr {int(rand() * 0xFFFFFFFF)}]]
		
	# Force signals to values
	force -freeze sel 00 0ms
	force -freeze a 10#$val1 0ms
	force -freeze b 10#$val2 0ms
	force -freeze c 10#$val3 0ms
	force -freeze d 10#$val4 0ms
		
	# ---------------------------------------------------------
	# GENERATE WAVEFORMS
	# ---------------------------------------------------------
	
	set runtime 0
	for {set i 0} {$i < 250} {incr i} {
		#increase time step
		set runtime [expr $runtime + 10]
		
		#gererate random select value
		set rand_sel [expr {int(rand() * 5) + 1}]
				
		#force signal to value
		if {$rand_sel == 0} {
			force -freeze sel 00 $runtime ms
		} elseif {$rand_sel == 1} {
			force -freeze sel 01 $runtime ms
		} elseif {$rand_sel == 2} {
			force -freeze sel 10 $runtime ms
		} elseif {$rand_sel == 3} {
			force -freeze sel 11 $runtime ms
		} elseif {$rand_sel == 4} {
			force -freeze sel uu $runtime ms
		} else {
			force -freeze sel zz $runtime ms
		}
		
	}	
	run $runtime ms
	
	# -----------------------------------------------------------
	# RUN WAVEFORM VERIFICATION
	# -----------------------------------------------------------
	
	for {set i 1} {$i < $runtime} {set i [expr $i + 10]} {
		set res_sel [examine -time $i ms -binary sel ]
		set res_o [examine -time $i ms -hexadecimal o ]

		if {$res_sel == "00"} {
			set res_a [examine -time $i ms -hexadecimal a ]
			if {$res_a == $res_o} {
				echo PASS $i ms: sel: $res_sel $res_a -> $res_o
			} else {
				echo FAIL $i ms: sel: $res_sel $res_a -> $res_o
			}
		} elseif {$res_sel == "01"} {
			set res_b [examine -time $i ms -hexadecimal b ]
			if {$res_b == $res_o} {
				echo PASS $i ms: sel: $res_sel $res_b -> $res_o
			} else {
				echo FAIL $i ms: sel: $res_sel $res_b -> $res_o
			}
		} elseif {$res_sel == "10"} {
			set res_c [examine -time $i ms -hexadecimal c ]
			if {$res_c == $res_o} {
				echo PASS $i ms: sel: $res_sel $res_c -> $res_o
			} else {
				echo FAIL $i ms: sel: $res_sel $res_c -> $res_o
			}
		} elseif {$res_sel == "11"} {
			set res_d [examine -time $i ms -hexadecimal d ]
			if {$res_d == $res_o} {
				echo PASS $i ms: sel: $res_sel $res_d -> $res_o
			} else {
				echo FAIL $i ms: sel: $res_sel $res_d -> $res_o
			}
		} else {
			if {$res_o == "ZZZZZZZZ"} {
				echo PASS $i ms: sel: $res_sel ZZZZZZZZ -> $res_o
			} else {
				echo FAIL $i ms: sel: $res_sel ZZZZZZZZ -> $res_o
			}
		}
	}
}