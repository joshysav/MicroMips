proc  write_word { addr data } {

    global array set memory {}

    force -freeze ce 1
    force -freeze we 1
    force -freeze oe 0
    force -freeze byte_sel 1111
    force -freeze addr 10#$addr
    force -freeze data 16#$data

    set memory($addr) [string toupper $data]

    echo "WRITE: \t\t$addr \t\t$data \t\t$memory($addr)"

    run 10ms
}

proc read_word { addr } {
    global array set memory {}

    noforce data
    force -freeze ce 1
    force -freeze we 0
    force -freeze oe 1
    force -freeze byte_sel 1111
    force -freeze addr 10#$addr

    run 1ms

    set data [examine -hexadecimal /ram/data ]

    if {$memory($addr) == $data} {
        echo "READ: \t\t$addr \t\t$data \t\t$memory($addr) \t\tPASS"
    } else {
        echo "READ: \t\t$addr \t\t$data \t\t$memory($addr) \t\tFAIL"
    }

    run 10ms
}

# CLEAR WAVEFORM
restart -force -nowave

# ADD SIGNALS
add wave clk
add wave ce
add wave oe
add wave we
add wave byte_sel
add wave -radix unsigned addr
add wave -radix hexadecimal data

add wave -radix hexadecimal /ram/mem_s

# RESET MEMORY
array set memory { }
for {set i 0} {$i < 1023} {incr i} {
    set memory($i) 0
}

# SIMULATE
force -freeze clk 1 0, 0 5ms -repeat 10ms

echo "-------------------------------------------------------------------"
echo "ACTION: \t\tADDR \t\tDATA \t\tMEMORY \t\tPASS"
echo "-------------------------------------------------------------------"
for {set i 0} {$i < 1000} {incr i} {
    set action [expr {int(rand() * 2)}]

    if {$action == 0} {
        set addr [expr {int(rand() * 4) * 4}]
        set data [format %08x [expr {int(rand() * 0xFFFFFFFF)}]]
        write_word $addr $data
    } else {
        set addr [expr {int(rand() * 4) * 4}]
        read_word $addr
    }
}

wave zoom full
