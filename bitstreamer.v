// bitstreamer module.
// author: David Ariando
// date: 2020/06/30
// this module streams out a synchronized output for FSK with corresponding
// control signal.

`timescale 1ns / 1ps

module bitstreamer 
#(
	parameter DATALEN = 64,
	parameter CNTLEN = 8,
	parameter CLK_DIV1 = 16,		// the bitstream1 frequency division factor from clock
	parameter CLK_DIV2 = 32			// the bitstream2 frequency division factor from clock
)
(
	input [DATALEN-1:0]	datain,
	input	[CNTLEN-1:0]	phase_delay,
	
	input clk,
	input start,
	input rst,
	
	output reg out,
	output reg bitout
);

	reg [DATALEN-1:0] datain_reg;
	reg [CNTLEN-1:0] phase_delay_reg;
	reg [CNTLEN-1:0] phase_delay_LOADVAL;
	reg [CNTLEN-1:0] halfclk_LOADVAL;
	reg [CNTLEN-1:0] taildelay_LOADVAL;
	reg [CNTLEN-1:0] datalen_LOADVAL;
	
	reg [5:0] State;
	localparam [5:0]
		S0 = 6'b000001,
		S1 = 6'b000010,
		S2 = 6'b000100,
		S3 = 6'b001000,
		S4 = 6'b010000,
		S5 = 6'b100000;

	always @(posedge clk, posedge rst)
	begin
		if (rst)
		begin
			State <= S0;
			out <= 1'b0;
		end
		
		else
		begin
		
			case (State)
			
				S0: // initial state
				begin
				
					datain_reg <= datain;
					phase_delay_reg <= phase_delay;
					datalen_LOADVAL <= {{1'b1},{(CNTLEN-1){1'b0}}} - DATALEN + 1'b1;
					out <= 1'b0;
					
					if (start)
						State <= S1;
						
				end
				
				S1: // delay state for phase control
				begin
					if (datain_reg[0]) // bitstream is 1, use the lowfreq stream
					begin
						phase_delay_LOADVAL <= {{1'b1},{(CNTLEN-1){1'b0}}} - (phase_delay_reg<<1) + 2'd2;
						halfclk_LOADVAL <= {{1'b1},{(CNTLEN-1){1'b0}}} - (CLK_DIV2>>1) + 1'b1;
						taildelay_LOADVAL <= {{1'b1},{(CNTLEN-1){1'b0}}} - (CLK_DIV2>>1) + (phase_delay_reg<<1) + 2'd2;
					end
						
					else // otherwise, use the highfreq stream
					begin
						phase_delay_LOADVAL <= {{1'b1},{(CNTLEN-1){1'b0}}} - phase_delay_reg + 2'd2;
						halfclk_LOADVAL <= {{1'b1},{(CNTLEN-1){1'b0}}} - (CLK_DIV1>>1) + 1'b1;
						taildelay_LOADVAL <= {{1'b1},{(CNTLEN-1){1'b0}}} - (CLK_DIV1>>1) + phase_delay_reg + 2'd2;
					end
					
					
					// start high pulse
					out <= 1'b1;
					bitout <= datain_reg[0];
						
					State <= S2;
				end
				
				S2: // counting phase delay
				begin
					phase_delay_LOADVAL <= phase_delay_LOADVAL + 1'b1;
					
					if (phase_delay_LOADVAL[CNTLEN-1])
						State <= S3;
				end
				
				S3: // transmit low pulse
				begin
				
					// start low pulse
					out <= 1'b0;
					
					halfclk_LOADVAL <= halfclk_LOADVAL + 1'b1;
					
					if (halfclk_LOADVAL[CNTLEN-1])
						State <= S4;
				end
				
				S4: // transmit high pulse tail
				begin
					
					// start high pulse
					out <= 1'b1;
					
					taildelay_LOADVAL <= taildelay_LOADVAL + 1'b1;
					
					if (taildelay_LOADVAL[CNTLEN-1])
						State <= S5;
					
				end
				
				S5: // check total bitstream
				begin
					
					datalen_LOADVAL <= datalen_LOADVAL + 1'b1;
					datain_reg <= datain_reg >> 1;
					
					
					if (datalen_LOADVAL[CNTLEN-1])
						State <= S0;
					else
						State <= S1;
					
				end
					
			endcase
		end
	end

endmodule
