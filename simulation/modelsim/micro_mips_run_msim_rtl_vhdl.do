transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/datapath.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/writeback_unit.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/execute_unit.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/decode_unit.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/fetch_unit.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/clock_unit.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/soc.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/chip_selector.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/core.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/rom.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/register_file.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/ram.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/control_unit.vhd}
vcom -93 -work work {/home/andris/Documents/digital_design/MicroMips/alu.vhd}

