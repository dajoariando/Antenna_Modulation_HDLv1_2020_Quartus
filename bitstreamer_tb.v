`timescale 1ns / 1ps

module bitstreamer_tb;

localparam DATALEN = 10;
localparam CNTLEN = 8;
localparam CLK_DIV1 = 16;		// the bitstream1 frequency division factor from clock
localparam CLK_DIV2 = 32;			// the bitstream2 frequency division factor from clock


reg [DATALEN-1:0]	datain;
reg [CNTLEN-1:0]	phase_delay;

reg clk;
reg start;
reg rst;

wire sysrun;
wire outp;
wire outn;



bitstreamer
#(
	.DATALEN (DATALEN),
	.CNTLEN (CNTLEN),
	.CLK_DIV1 (CLK_DIV1),		// the bitstream1 frequency division factor from clock
	.CLK_DIV2 (CLK_DIV2)			// the bitstream2 frequency division factor from clock
)
dut
(
	.datain	(datain),
	.phase_delay (phase_delay),
	
	.clk		(clk),
	.start	(start),
	.rst		(rst),
	
	.sysrun		(sysrun),
	.outp		(outp),
	.outn		(outn),
	.bitout	(bitout)
);

	//
	// System Clock Emulation
	//
	localparam CLK_RATE_HZ = 4000000; // 4 MHz
	localparam CLK_HALF_PER = ((1.0 / CLK_RATE_HZ) * 1000000000.0) / 2.0; // ns	
	initial
	begin
		clk = 1'b0;
		forever #(CLK_HALF_PER) clk = ~clk;
	end
	
	initial
	begin
		// datain = 10'b1111111111;
		datain = 10'b0;
		phase_delay = 6;
		rst = 1;
		start = 0;
		
		#(CLK_HALF_PER);
		
		#(2*CLK_HALF_PER) rst = 0;
		
		#(2*CLK_HALF_PER) start = 1;
		#(2*CLK_HALF_PER) start = 0;
		
		
	end

endmodule
