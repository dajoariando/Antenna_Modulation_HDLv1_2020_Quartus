# Get the list of avalon memory map master services
set masters [get_service_paths master]

# Select the first master (the JTAG to avalon master)
set master [lindex $masters 0]

# Open the master service
open_service master $master

# Set led and switches address (see the address on Qsys)
set led_addr 0x20
set sw_addr 0x10
set dly_addr 0x30
set datain3 0x50
set datain2 0x60
set datain1 0x70
set datain0 0x40
set start	0x00

# Write to the LEDs.
# Do this several times but change 0xF0 to different hexadecimal value, e.g. 0x00, 0x0F, 0x10, 0x20, etc
# master_write_16 $master $led_addr 0xF0

# Read 16-bits the switches status 1 time
# Do this several times and change the switches state
# master_read_16 $master $sw_addr 1

# Write delay. Avoid to use 0x01 and (CLK_DIV1/2-1) for the delay number because it will reduce the clock a little bit. All numbers between are valid.
master_write_32 $master $dly_addr 0x4

# Send bit sequence
# set x [expr {round(rand()*0xFFFFFFFF)}]
# master_write_32 $master $datain3 $x
# set x [expr {round(rand()*0xFFFFFFFF)}]
# master_write_32 $master $datain2 $x
# set x [expr {round(rand()*0xFFFFFFFF)}]
# master_write_32 $master $datain1 $x
# set x [expr {round(rand()*0xFFFFFFFF)}]
# master_write_32 $master $datain0 $x


master_write_32 $master $datain3 0x0F020FDF
master_write_32 $master $datain2 0x54A3A0DF
master_write_32 $master $datain1 0x1B6F0B70
master_write_32 $master $datain0 0xFCC8090E

# master_write_32 $master $datain3 0xF0F0F0F0
# master_write_32 $master $datain2 0xFF00FF00
# master_write_32 $master $datain1 0xFFFF0000
# master_write_32 $master $datain0 0xFFFF0000

# master_write_32 $master $datain3 0xFFFFFFFF
# master_write_32 $master $datain2 0xFFFFFFFF
# master_write_32 $master $datain1 0xFFFFFFFF
# master_write_32 $master $datain0 0xFFFFFFFF

# master_write_32 $master $datain3 0x0
# master_write_32 $master $datain2 0x0
# master_write_32 $master $datain1 0x0
# master_write_32 $master $datain0 0x0

# Start the sequence
master_write_16 $master $start 0x1
master_write_16 $master $start 0x0

# Close the master service
close_service master $master