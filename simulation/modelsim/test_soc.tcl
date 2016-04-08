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
add wave -radix hexadecimal -label RS_OUTPUT sim:/soc/core_inst/datap/decode_u/rs
add wave -radix hexadecimal -label RT_OUTPUT sim:/soc/core_inst/datap/decode_u/rt

set FETCH_STATE 'FETCH'
set DECODE_STATE 1
set ALU_1_STATE 2
set CURRENT_STATE $FETCH_STATE

force -freeze clk 1 0, 0 5 ms -repeat 10 ms
force -freeze rst 0 0, 1 1 ms
run 1ms;

for {set i 0} {$i < 10} {incr i} {


    set step_state [examine /soc/core_inst/cu/state]

    echo $step_state
    if { $step_state == $FETCH_STATE } {

    }
    run 10 ms
}


#force -freeze clk 1 0, 0 5 ms -repeat 10 ms
#force -freeze rst 0 0, 1 1 ms

#run 200 ms
wave zoom full
