proc run_test {} {
	restart -force -nowave
	
	#Add signals to wave
	add wave -color blue -radix decimal op_a
	add wave -color blue -radix decimal op_b
	add wave -color blue -logic fn_class
	add wave -color blue -logic logic_fn
	add wave -color blue -logic arith_fn
	add wave -color blue -radix decimal result
	add wave -color blue -logic ovfl
	
	set runtime 0
	set step 10
	
	set LUI 	0
	set	SLTI	1
	set ADD 	2
	set SUB 	3
	set AND		4
	set OR		5
	set	XOR		6
	set NOR		7
	
	# ================================================================
	# Run simulation
	# ================================================================
	for {set i 0} {$i < 100} {incr i} {
		# Generate random operands	
		set operand_a [format %x [expr {int(rand() * 0xFFFFFFFF)}]]
		set operand_b [format %x [expr {int(rand() * 0xFFFFFFFF)}]]
		
		# Generate random function		
		# At the monent only ADD is implemented so set it to 0
		set function [expr {int(rand() * 8)}]
		#set function $SLTI
		
		if {$function == $LUI} {
		    lui $operand_b $runtime
		} elseif {$function == $SLTI} {
		    slti $operand_a $operand_b $runtime
		} elseif {$function == $ADD} {
		    add_op $operand_a $operand_b $runtime
		} elseif {$function == $SUB} {
		    sub_op $operand_a $operand_b $runtime
		} elseif {$function == $AND} {
		    and_op $operand_a $operand_b $runtime
		} elseif {$function == $OR} {
		    or_op $operand_a $operand_b $runtime
		} elseif {$function == $XOR} {
		    xor_op $operand_a $operand_b $runtime
		} elseif {$function == $NOR} {
		    nor_op $operand_a $operand_b $runtime
		}
		
		# Increment time step
		set runtime [expr $runtime + $step]
	}
	
	
	run $runtime ms
	
	# ================================================================	
	# Examine results
	# ================================================================
	for {set i 1} {$i < $runtime} {set i [expr $i + $step]} {
		
		set f_class [examine -time $i ms -unsigned /alu/fn_class]
		set arith_f [examine -time $i ms -unsigned /alu/arith_fn]
		set logic_f [examine -time $i ms -unsigned /alu/logic_fn]
		
		# ============================================================
		# 	LUI
		# ============================================================
		if { $f_class == 0 } {
			set b [examine -time $i ms -hexadecimal /alu/op_b]
			set r [examine -time $i ms -hexadecimal /alu/result]
			
			echo ""
			echo ""
			echo " LUI"
			echo "----------------------------------------------"
			echo "time\t\t: $i ms"
			echo "f_class\t\t: $f_class"
			echo "op_b\t\t: $b"
			echo "result\t\t: $r"
			
			echo "test\t\t: Must be inspected manualy, because tcl doesnt support unsgigned shifts"
		
		# ============================================================
		# 	SLTI
		# ============================================================
		} elseif { $f_class == 1} {
			set a [examine -time $i ms -decimal /alu/op_a]
			set b [examine -time $i ms -decimal /alu/op_b]
			set r [examine -time $i ms -decimal /alu/result]
			set res [expr ($a < $b) ? 1 : 0]	
			
			echo ""
			echo ""
			echo " SLTI"
			echo "----------------------------------------------"
			echo "time\t\t: $i ms"
			echo "f_class\t\t: $f_class"
			echo "op_a\t\t: $a"
			echo "op_b\t\t: $b"
			echo "result\t\t: $r"
			echo "expected_res\t\t: $res"
			
			# If caclulation is correct
			if { $r != $res} {
				echo "test\t\t: FAIL"
			} else {
				echo "test\t\t: PASS"
			}
		# ============================================================
		# 	ADD
		# ============================================================
		} elseif { $f_class == 2 && $arith_f == 0} {
			set a [examine -time $i ms -decimal /alu/op_a]
			set b [examine -time $i ms -decimal /alu/op_b]
			set r [examine -time $i ms -decimal /alu/result]
			set o [examine -time $i ms -unsigned /alu/ovfl]
			set res [expr $a + $b]	
			
			echo ""
			echo ""
			echo " ADD"
			echo "----------------------------------------------"
			echo "time\t\t: $i ms"
			echo "f_class\t\t: $f_class"
			echo "arith_f\t\t: $arith_f"
			echo "op_a\t\t: $a"
			echo "op_b\t\t: $b"
			echo "result\t\t: $r"
			echo "expected_res\t\t: $res"
			echo "overflow\t\t: $o"
			
			# If caclulation is correct
			if { $r != $res} {
				if {$o == 0} {
					echo "test\t\t: FAIL (Result overflow, but flag NOT set)"
				} elseif { $o == 1} {
					echo "test\t\t: PASS (Result overflow, flag set)"
				} else {
					echo "test\t\t: FAIL (Result overflow, UNKNOWN flag)"
				}
			} else {
				if {$o == 0} {
					echo "test\t\t: PASS (Result NO overflow, flag NOT set)"
				} elseif { $o == 1} {
					echo "test\t\t: FAIL (Result NO overflow, flag set)"
				} else {
					echo "test\t\t: FAIL (Result NO overflow, UNKNOWN flag)"
				}
			}
		# ============================================================
		# 	SUBTRACT
		# ============================================================	
		} elseif {$f_class == 2 && $arith_f == 1} {
			set a [examine -time $i ms -decimal /alu/op_a]
			set b [examine -time $i ms -decimal /alu/op_b]
			set r [examine -time $i ms -decimal /alu/result]
			set o [examine -time $i ms -unsigned /alu/ovfl]
			set res [expr $a - $b]
			
			echo ""
			echo ""
			echo " SUBTRACT"
			echo "----------------------------------------------"
			echo "time\t\t: $i ms"
			echo "f_class\t\t: $f_class"
			echo "arith_f\t\t: $arith_f"
			echo "op_a\t\t: $a"
			echo "op_b\t\t: $b"
			echo "result\t\t: $r"
			echo "expected_res\t\t: $res"
			echo "overflow\t\t: $o"
			
			# If caclulation is correct
			if { $r != $res} {
				if {$o == 0} {
					echo "test\t\t: FAIL (Result overflow, but flag NOT set)"
				} elseif { $o == 1} {
					echo "test\t\t: PASS (Result overflow, flag set)"
				} else {
					echo "test\t\t: FAIL (Result overflow, UNKNOWN flag)"
				}
			} else {
				if {$o == 0} {
					echo "test\t\t: PASS (Result NO overflow, flag NOT set)"
				} elseif { $o == 1} {
					echo "test\t\t: FAIL (Result NO overflow, flag set)"
				} else {
					echo "test\t\t: FAIL (Result NO overflow, UNKNOWN flag)"
				}
			}	
		# ============================================================
		# 	AND
		# ============================================================	
		} elseif {$f_class == 3 && $logic_f == 0} {
			set a [examine -time $i ms -decimal /alu/op_a]
			set b [examine -time $i ms -decimal /alu/op_b]
			set r [examine -time $i ms -decimal /alu/result]
			set res [expr $a & $b]	
			
			echo ""
			echo ""
			echo " AND"
			echo "----------------------------------------------"
			echo "time\t\t: $i ms"
			echo "f_class\t\t: $f_class"
			echo "arith_f\t\t: $arith_f"
			echo "op_a\t\t: $a"
			echo "op_b\t\t: $b"
			echo "result\t\t: $r"
			echo "expected_res\t\t: $res"
			
			# If caclulation is correct
			if { $r != $res} {
				echo "test\t\t: FAIL"
			} else {
				echo "test\t\t: PASS"
			}	
		# ============================================================
		# 	OR
		# ============================================================	
		} elseif {$f_class == 3 && $logic_f == 1} {
			set a [examine -time $i ms -decimal /alu/op_a]
			set b [examine -time $i ms -decimal /alu/op_b]
			set r [examine -time $i ms -decimal /alu/result]
			set res [expr $a | $b]	
			
			echo ""
			echo ""
			echo " OR"
			echo "----------------------------------------------"
			echo "time\t\t: $i ms"
			echo "f_class\t\t: $f_class"
			echo "arith_f\t\t: $arith_f"
			echo "op_a\t\t: $a"
			echo "op_b\t\t: $b"
			echo "result\t\t: $r"
			echo "expected_res\t\t: $res"
			
			# If caclulation is correct
			if { $r != $res} {
				echo "test\t\t: FAIL"
			} else {
				echo "test\t\t: PASS"
			}	
		# ============================================================
		# 	XOR
		# ============================================================	
		} elseif {$f_class == 3 && $logic_f == 2} {
			set a [examine -time $i ms -decimal /alu/op_a]
			set b [examine -time $i ms -decimal /alu/op_b]
			set r [examine -time $i ms -decimal /alu/result]
			set res [expr $a ^ $b]	
			
			echo ""
			echo ""
			echo " XOR"
			echo "----------------------------------------------"
			echo "time\t\t: $i ms"
			echo "f_class\t\t: $f_class"
			echo "arith_f\t\t: $arith_f"
			echo "op_a\t\t: $a"
			echo "op_b\t\t: $b"
			echo "result\t\t: $r"
			echo "expected_res\t\t: $res"
			
			# If caclulation is correct
			if { $r != $res} {
				echo "test\t\t: FAIL"
			} else {
				echo "test\t\t: PASS"
			}	
		# ============================================================
		# 	NOR
		# ============================================================	
		} elseif {$f_class == 3 && $logic_f == 3} {
			set a [examine -time $i ms -decimal /alu/op_a]
			set b [examine -time $i ms -decimal /alu/op_b]
			set r [examine -time $i ms -decimal /alu/result]
			set res [expr ~($a | $b)]	
			
			echo ""
			echo ""
			echo " NOR"
			echo "----------------------------------------------"
			echo "time\t\t: $i ms"
			echo "f_class\t\t: $f_class"
			echo "arith_f\t\t: $arith_f"
			echo "op_a\t\t: $a"
			echo "op_b\t\t: $b"
			echo "result\t\t: $r"
			echo "expected_res\t\t: $res"
			
			# If caclulation is correct
			if { $r != $res} {
				echo "test\t\t: FAIL"
			} else {
				echo "test\t\t: PASS"
			}	
		}      
	}
}

proc lui {b time} {
	force -freeze op_b 16#$b $time ms
	force -freeze fn_class 00 $time ms
}

proc slti {a b time} {
	force -freeze op_a 16#$a $time ms
	force -freeze op_b 16#$b $time ms
	force -freeze fn_class 01 $time ms
}

proc add_op {a b time} {
	force -freeze op_a 16#$a $time ms
	force -freeze op_b 16#$b $time ms
	force -freeze fn_class 10 $time ms
	force -freeze arith_fn 0 $time ms
}

proc sub_op {a b time} {
	force -freeze op_a 16#$a $time ms
	force -freeze op_b 16#$b $time ms
	force -freeze fn_class 10 $time ms
	force -freeze arith_fn 1 $time ms
}

proc and_op {a b time} {
	force -freeze op_a 16#$a $time ms
	force -freeze op_b 16#$b $time ms
	force -freeze fn_class 11 $time ms
	force -freeze logic_fn 00 $time ms
}

proc or_op {a b time} {
	force -freeze op_a 16#$a $time ms
	force -freeze op_b 16#$b $time ms
	force -freeze fn_class 11 $time ms
	force -freeze logic_fn 01 $time ms
}

proc xor_op {a b time} {
	force -freeze op_a 16#$a $time ms
	force -freeze op_b 16#$b $time ms
	force -freeze fn_class 11 $time ms
	force -freeze logic_fn 10 $time ms
}

proc nor_op {a b time} {
	force -freeze op_a 16#$a $time ms
	force -freeze op_b 16#$b $time ms
	force -freeze fn_class 11 $time ms
	force -freeze logic_fn 11 $time ms
}
