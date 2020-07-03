/*
this module is to generate a single pulse with defined length for a single activation signal
this will prevent multiple pulse generated with a single activation pulse just because the activation pulse is really long (more than the time needed for the FSM to finish)
the minimum distance for activation is 2 clock cycle, in order to generate correct signal
*/

`timescale 1ps / 1ps
 
module GNRL_delayed_pulser
#(
	parameter DELAY_WIDTH = 32
)(
	// signals
	input SIG_IN,
	output reg SIG_OUT,
	
	// parameters
	input [DELAY_WIDTH-1:0] DELAY,
	
	// system
	input CLK,
	input RESET
	
);
	
	reg [DELAY_WIDTH-1:0] DELAY_CNT;
	
	reg [4:0] State;
	localparam [4:0]
		S0 = 5'b00001,
		S1 = 5'b00010,
		S2 = 5'b00100,
		S3 = 5'b01000,
		S4 = 5'b10000;

		
	initial
	begin
		DELAY_CNT <= {DELAY_WIDTH{1'b0}};
		SIG_OUT <= 1'b0;
		State <= S0;
	end
	
	always @(posedge CLK, posedge RESET)
	begin
	
		if (RESET)
		begin
		
			DELAY_CNT <= {DELAY_WIDTH{1'b0}};
			SIG_OUT <= 1'b0;
									
			State <= S0;
			
		end
		else
		begin
		
			case (State)
			
				S0 : // init delay, check sig_in edge
				begin
					
					DELAY_CNT <= {1'b1,{(DELAY_WIDTH-1){1'b0}}} - DELAY + 1'b1 + 1'b1; // (+1'b1) is for compensating S1-S2 transition
					
					if (SIG_IN)
						State <= S1;
				
				end
				
				S1 : // add delay
				begin
					
					DELAY_CNT = DELAY_CNT + 1'b1; 
					
					if (DELAY_CNT[DELAY_WIDTH-1])
						State <= S2;

				end
				
				S2 : // assert signal
				begin
				
					SIG_OUT <= 1'b1;
					
					State <= S3;
					
				end
				
				S3 : // deassert signal
				begin
				
					SIG_OUT <= 1'b0;
					
					State <= S4;
					
				end
				
				S4 : // wait for sig_in to be 0 (effectively searching for sig_in edge)
				begin
				
					if (!SIG_IN)
						State <= S0;
				
				end
				
			endcase
		
		end
	
	end

	

endmodule