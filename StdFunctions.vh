//////////////////////////////////////////////////////////////////////////////////
// Company: Case Western Reserve University
// Engineer: Matt McConnell
// 
// Create Date:    18:11:00 02/09/2017 
// Project Name:   EECS301 Digital Design
// Target Devices: Altera Cyclone V
// Tool versions:  Quartus v15.0
// Description:    Standard Function Include File
//                 Commonly used functions.
//                 
//////////////////////////////////////////////////////////////////////////////////

//`ifndef _StdFunctions_vh_
//`define _StdFunctions_vh_


	// Helper function to find the upper index needed 
	// for a register to hold the given value.
	function integer bit_index;
		input integer x;
		integer i,p;
	begin
		p = 2;
		for(i=1; p<=x; i=i+1)
			p=p*2;
		bit_index=i;
	end
	endfunction

	
	//
	// Compute 2 to the power N with integer input and output
	// NOTE: Quarts does not handle 2**N properly in all cases
	//
	function integer pow2;
		input integer n;
		integer x,i;
	begin
		x=1;
		for(i=0; i < n; i=i+1)
			x=x*2;
		pow2=x;
	end
	endfunction
	


//`endif // _StdFunctions_vh_
