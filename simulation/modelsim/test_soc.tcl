# CLEAR WAVEFORM
restart -force -nowave

# -----------------------------------------------------------------
# ADD SIGNALS
# -----------------------------------------------------------------
add wave rst
add wave clk
add wave -color blue sys_clk_s

# CONTROL UNIT
# -----------------------------------------------------
add wave -noupdate -divider -height 48 CONTROL_UNIT
add wave -color orange /soc/core_inst/cu/state
add wave /soc/core_inst/cu/op
add wave /soc/core_inst/cu/fn

# FETCH UNIT
# -----------------------------------------------------
add wave -noupdate -divider -height 48 FETCH_UNIT
add wave -radix hexadecimal -label PC /soc/core_inst/datap/fetch_u/pc_out
add wave -radix hexadecimal -label IR /soc/core_inst/datap/fetch_u/ir_out
add wave -radix hexadecimal -label DR /soc/core_inst/datap/fetch_u/dr_out

# DECODE UNIT
# -----------------------------------------------------
add wave -noupdate -divider -height 48 DECODE_UNIT

add wave -noupdate -divider -height 24 Instruction
add wave -radix binary -label OPCODE {/soc/core_inst/datap/decode_u/instr[31:26]}
add wave -radix unsigned -label RS {/soc/core_inst/datap/decode_u/instr[25:21]}
add wave -radix unsigned -label RT {/soc/core_inst/datap/decode_u/instr[20:16]}
add wave -radix unsigned -label RD {/soc/core_inst/datap/decode_u/instr[15:11]}
add wave  -label FUNCTION {/soc/core_inst/datap/decode_u/instr[5:0]}
add wave -noupdate -divider -height 24 Selected_registers
add wave -radix unsigned -label RS_INDEX /soc/core_inst/datap/decode_u/reg_file/rs_sel
add wave -radix unsigned -label RT_INDEX /soc/core_inst/datap/decode_u/reg_file/rt_sel
add wave -radix unsigned -label RD_INDEX /soc/core_inst/datap/decode_u/reg_file/rd_sel
add wave -noupdate -divider -height 24 Outputs
add wave -radix hexadecimal -label RS_OUTPUT sim:/soc/core_inst/datap/decode_u/reg_file/rs_data_s
add wave -radix hexadecimal -label RS_OUTPUT sim:/soc/core_inst/datap/decode_u/reg_file/rt_data_s
add wave -radix hexadecimal -label RT_OUTPUT sim:/soc/core_inst/datap/decode_u/rt
add wave -radix binary -label REG_FILE sim:/soc/core_inst/datap/decode_u/reg_file/register_f_s

add wave -noupdate -divider -height 25 REG_FILE_OUT
add wave -radix binary -label X_REG sim:/soc/core_inst/datap/decode_u/x_register
add wave -radix binary -label Y_REG sim:/soc/core_inst/datap/decode_u/y_register
add wave -radix binary -label RD_DATA  sim:/soc/core_inst/datap/decode_u/data
add wave -radix hexadecimal -label PC_IN /soc/core_inst/datap/fetch_u/pc_in
add wave -radix hexadecimal -label RS_OUT sim:/soc/core_inst/datap/decode_u/rs
add wave -radix hexadecimal -label RT_OUT sim:/soc/core_inst/datap/decode_u/rt


# EXECUTE UNIT
# ----------------------------------------------------
add wave -noupdate -divider -height 48 EXECUTE_UNIT

add wave -radix decimal -label ALU_OP_A sim:/soc/core_inst/datap/execute_u/op_a_sig
add wave -radix decimal -label ALU_OP_B sim:/soc/core_inst/datap/execute_u/op_b_sig
add wave -radix decimal -label Z_REGISTER sim:/soc/core_inst/datap/writeback_u/z_reg

proc check_pc_increment {step_state FETCH_STATE prev_pc args} {
  if { $step_state == $FETCH_STATE } {

      set PC [examine -radix decimal /soc/core_inst/datap/fetch_u/pc_out]
      echo "PC : " $PC;

      # has pc been incremented by 4
        if { [expr $prev_pc + 4] != $PC} {
            echo "-----------";
            echo "Fail";
            echo "PC value not incremented by 4";
            echo "-----------";
        }

      # update pc
        set prev_pc $PC

  }
}

force -freeze sim:/soc/core_inst/datap/decode_u/reg_file/register_f_s(0) 00000000000000000000000000000100
force -freeze sim:/soc/core_inst/datap/decode_u/reg_file/register_f_s(1) 00000000000000000000000000000011

set FETCH_STATE "FETCH"
set DECODE_STATE "DECODE"
set ALU_1_STATE 2
set CURRENT_STATE $FETCH_STATE


force -freeze clk 1 0, 0 5 ms -repeat 10 ms
force -freeze rst 0 0, 1 1 ms
run 1ms;


# 10 states
set prev_pc 0
for {set i 0} {$i < 10} {incr i} {

    set step_state [examine /soc/core_inst/cu/state]
    echo $step_state

     # check_pc_increment $step_state $FETCH_STATE $prev_pc

    if { $step_state == $DECODE_STATE } {

        echo "X Register: [examine -radix hexadecimal sim:/soc/core_inst/datap/decode_u/x_register ]";
        echo "Y Register: [examine -radix hexadecimal sim:/soc/core_inst/datap/decode_u/y_register ]";


    }



    run 10 ms
}



#force -freeze clk 1 0, 0 5 ms -repeat 10 ms
#force -freeze rst 0 0, 1 1 ms

#run 300 ms
wave zoom full
