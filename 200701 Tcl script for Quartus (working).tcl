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
set bitstream 0x40
set start	0x00

# Write to the LEDs.
# Do this several times but change 0xF0 to different hexadecimal value, e.g. 0x00, 0x0F, 0x10, 0x20, etc
# master_write_16 $master $led_addr 0xF0

# Read 16-bits the switches status 1 time
# Do this several times and change the switches state
# master_read_16 $master $sw_addr 1

# Write delay
master_write_32 $master $dly_addr 0x07

# Send bit sequence
# master_write_32 $master $bitstream 0xFFFFFFFF
# master_write_32 $master $bitstream 0x00000000
master_write_32 $master $bitstream 0xFF0000F0

# Start the sequence
master_write_16 $master $start 0x1
master_write_16 $master $start 0x0

# Close the master service
close_service master $master