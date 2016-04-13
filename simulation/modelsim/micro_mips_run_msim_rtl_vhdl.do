transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/datapath.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/writeback_unit.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/execute_unit.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/decode_unit.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/fetch_unit.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/clock_unit.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/soc.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/chip_selector.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/core.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/rom.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/register_file.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/ram.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/control_unit.vhd}
vcom -93 -work work {/home/josh/Documents/assignment/MicroMips/alu.vhd}

