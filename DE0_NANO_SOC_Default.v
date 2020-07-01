//`define ENABLE_HPS
module DE0_NANO_SOC_Default(

	//////////// ADC //////////
	output		          		ADC_CONVST,
	output		          		ADC_SCK,
	output		          		ADC_SDI,
	input 		          		ADC_SDO,
	//////////// CLOCK //////////
	input 		          		FPGA_CLK1_50,
	input 		          		FPGA_CLK2_50,
	input 		          		FPGA_CLK3_50,
	
`ifdef ENABLE_HPS
	//////////// HPS //////////
	inout 		          		HPS_CONV_USB_N,
	output		    [14:0]		HPS_DDR3_ADDR,
	output		     [2:0]		HPS_DDR3_BA,
	output		          		HPS_DDR3_CAS_N,
	output		          		HPS_DDR3_CK_N,
	output		          		HPS_DDR3_CK_P,
	output		          		HPS_DDR3_CKE,
	output		          		HPS_DDR3_CS_N,
	output		     [3:0]		HPS_DDR3_DM,
	inout 		    [31:0]		HPS_DDR3_DQ,
	inout 		     [3:0]		HPS_DDR3_DQS_N,
	inout 		     [3:0]		HPS_DDR3_DQS_P,
	output		          		HPS_DDR3_ODT,
	output		          		HPS_DDR3_RAS_N,
	output		          		HPS_DDR3_RESET_N,
	input 		          		HPS_DDR3_RZQ,
	output		          		HPS_DDR3_WE_N,
	output		          		HPS_ENET_GTX_CLK,
	inout 		          		HPS_ENET_INT_N,
	output		          		HPS_ENET_MDC,
	inout 		          		HPS_ENET_MDIO,
	input 		          		HPS_ENET_RX_CLK,
	input 		     [3:0]		HPS_ENET_RX_DATA,
	input 		          		HPS_ENET_RX_DV,
	output		     [3:0]		HPS_ENET_TX_DATA,
	output		          		HPS_ENET_TX_EN,
	inout 		          		HPS_GSENSOR_INT,
	inout 		          		HPS_I2C0_SCLK,
	inout 		          		HPS_I2C0_SDAT,
	inout 		          		HPS_I2C1_SCLK,
	inout 		          		HPS_I2C1_SDAT,
	inout 		          		HPS_KEY,
	inout 		          		HPS_LED,
	inout 		          		HPS_LTC_GPIO,
	output		          		HPS_SD_CLK,
	inout 		          		HPS_SD_CMD,
	inout 		     [3:0]		HPS_SD_DATA,
	output		          		HPS_SPIM_CLK,
	input 		          		HPS_SPIM_MISO,
	output		          		HPS_SPIM_MOSI,
	inout 		          		HPS_SPIM_SS,
	input 		          		HPS_UART_RX,
	output		          		HPS_UART_TX,
	input 		          		HPS_USB_CLKOUT,
	inout 		     [7:0]		HPS_USB_DATA,
	input 		          		HPS_USB_DIR,
	input 		          		HPS_USB_NXT,
	output		          		HPS_USB_STP,
`endif /*ENABLE_HPS*/

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [7:0]		LED,

	//////////// SW //////////
	input 		     [3:0]		SW,

	//////////// GPIO_0, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO_1
);

	//=======================================================
	//  REG/WIRE declarations
	//=======================================================
	// reg  [31:0]	Cont;
	
	localparam DATALEN = 32;
	localparam CNTLEN = 8;
	localparam CLK_DIV1 = 16;		// the bitstream1 frequency division factor from clock. PLL should be 4MHz*factor
	localparam CLK_DIV2 = 32;			// the bitstream2 frequency division factor from clock. PLL output should be 2MHz*factor
	wire [DATALEN-1:0]	datain;
	wire [CNTLEN-1:0]	phase_delay;
	wire ant_clk;
	wire start;
	wire rst;
	wire outp;
	wire outn;
	wire sysrun;
	wire cnt_start;
	
	
	//=======================================================
	//  Structural coding
	//=======================================================


    system u0 (
        .clk_clk               (FPGA_CLK1_50),		//            clk.clk
        .reset_reset_n         (rst),				//          reset.reset_n
        .datain_export         (datain),				//         datain.export
        .ph_dly_export         (phase_delay),		//         ph_dly.export
        .ant_clk_clk           (ant_clk),				//        ant_clk.clk
        .ant_clk_locked_export (LED[7]),  // ant_clk_locked.export
		  .led_export            (LED[6:0]),            //            led.export
        .sw_export             (SW[3:0]),
			.cnt_start_export      (cnt_start)		  // 
    );

	 
	
	
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
		
		.clk		(ant_clk),
		.start	(start),
		.rst		(~rst),
		
		.sysrun		(sysrun),
		.outp		(outp),
		.outn		(outn),
		.bitout	(bitout)
	);
	
	// pin assignments
	assign start 	= ~KEY[1] || cnt_start;
	assign rst 		= KEY[0];
	assign GPIO_0[1] = outp;
	assign GPIO_0[3] = outn;
	assign GPIO_0[5] = bitout;
	assign GPIO_1[1] = outp;
	assign GPIO_1[3] = outn;
	assign GPIO_1[5] = bitout;
	
	assign GPIO_0[15] = outp; // highfet 1
	assign GPIO_0[17] = outn || (~sysrun); // lowfet 1
	assign GPIO_0[19] = outn; // highfet 2
	assign GPIO_0[21] = outp || (~sysrun); // lowfet 2
	assign GPIO_0[23] = bitout; // damp1
	assign GPIO_0[25] = bitout; // damp2
	
	assign GPIO_1[15] = outp; // highfet 1
	assign GPIO_1[17] = outn || (~sysrun);// lowfet 1
	assign GPIO_1[19] = outn; // highfet 2
	assign GPIO_1[21] = outp || (~sysrun); // lowfet 2
	assign GPIO_1[23] = bitout; // damp1
	assign GPIO_1[25] = bitout; // damp2
	
	/*
	assign GPIO_0  		=	36'hzzzzzzzz;
	assign GPIO_1  		=	36'hzzzzzzzz;

	always@(posedge FPGA_CLK1_50 or negedge KEY[0])
		 begin
			  if(!KEY[0])
				 Cont	<=	0;
			  else
				 Cont	<=	Cont+1;
		 end
		 
	assign	LED =	KEY[0]? {Cont[25:24],Cont[25:24],Cont[25:24],
										  Cont[25:24],Cont[25:24]}:10'h3ff;
	*/
									  
endmodule
