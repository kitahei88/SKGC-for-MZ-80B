`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:03:45 05/11/2025 
// Design Name: 
// Module Name:    main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`default_nettype none
/*  
    Addressdecoder for MZ-80B to MZ-2000  
    topmodule
    2024.06.12 kitahei88, Takuya Fukuda
    ATF15XX series
    4MHz  1clk = 250ns
*/

 module MZG1
(
    input CLK,          // 4MHz clk from MZ-80B
 //   input RST,          // Reset signal from MZ-80B
    input DSPAD, DSP, nMRAM, // nMRAM is L to All ram mode, H is IPL ROM , nMRAM means Reset signal. 
    input [3:0]AD,      // A15 to A12   
    input nEXWAIT,
    input nRFSH, nMREQ, nIORQ, nRD, nM1,    // for CPU signal
    input Bn2000,
	 input BLANK,
//	 input BLANK_2K, BLANK_B,
	 input delayLCSW,		// external delayed LCSW AND fast LCSW for BUFGM
	 
    output nRAS0, nRAS1, nRAS2, nRAS3, fastLCSW,   // nRAS0 to nRAS3. LCSW is MUX, L is row address and nCAS to H , H is column address and nCAS to L, need delay circuit.
    output LCSW, // real LCSW , L is Row address and H is Column address
	 output nCSED, nCSDD,    // for MZ-80B, MZ-2000 , GRAM, CGRAM select
    output nROMCS,
	 output BUFGM, BUFG0,  // BUFGM is memory,L RD(DRAM Dout on Data bus) H WD(DRAM Dout off Data bus).  BUFG0 is CPU L=RD,H=WD.
    output nWAIT
//    output tp1
);
//    wire nGRAM_stat ;
//    assign nGRAM_stat = nCSED & nCSDD ;
//    assign tp1 = nGRAM_stat;
	
//	 wire BLANK;
//	 assign BLANK = (Bn2000 ? BLANK_B : BLANK_2K);
	 
    reg [2:0]cnt; // 3bit  clock counter 0~7
    always @(posedge CLK or posedge nMREQ) begin
        if (nMREQ) begin
            cnt <= 3'b0;
        end else begin
            cnt <= cnt + 3'b001;
		end
    end

    // nRAS0~3
    // MZ-80B access 4116 DRAM, READ CYCLE TIMING, WRITE CYCLE TIMING and nRAS only refresh timing mode.
    // READ is made from nMREQ and nRD, Write is made from nMREQ and ~nRD
    // refresh made from nRFSH
    // not affect Bn2000
    assign nRAS0 = ( nMREQ | 
									( ( nMRAM ? ~(AD[3:2] == 2'b10)     // IPL status , AD 0x8000~0xBFFF  
                                     : ~(AD[3:2] == 2'b00) )   // ALL RAM status , AD 0x0000~0x3FFF
									  & nRFSH ) 								// refresh status 
									);                        			                       
 
    assign nRAS1 = ( nMREQ | 
									( ( nMRAM ? ~(AD[3:2] == 2'b11)     // IPL status , AD 0xC000~0xFFFF  
                                     : ~(AD[3:2] == 2'b01) )   // ALL RAM status , AD 0x4000~0x7FFF
									  & nRFSH )  								// refresh status  
									);                                           

    assign nRAS2 = ( nMREQ | 
									( ( nMRAM ? 1      						// IPL status , not assert  
                                     : ~(AD[3:2] == 2'b10) ) 	// ALL RAM status , AD 0x8000~0xBFFF
									  & nRFSH ) 									// refresh status 
									);                                            

    assign nRAS3 = ( nMREQ | 
									( ( nMRAM ? 1    							 // IPL status , not assert  
                                     : ~(AD[3:2] == 2'b11) ) 	 // ALL RAM status , AD 0xC000~0xFFFF
									  & nRFSH )  									 // refresh status 
									);                                                                        

    // LCSW means MUX ROW and COLOUM
    // assert with RAS but not RFSH status
    // not affect Bn2000 , need external delay circuit(50ns)
    assign fastLCSW = (nRFSH ? ~(nRAS0 & nRAS1 & nRAS2 & nRAS3) : 1'b0);
	 assign LCSW = fastLCSW & delayLCSW;
	 
    // nWAIT
    // CSED and CSDD while BLANK
    // nEXWAIT can assert nWAIT
    // IPL ROM access
    // until wait , no refresh occure, wait is stop z80 cpu at T2 state.
    assign nWAIT =  nEXWAIT // wait from external board
                    & ( BLANK | ( csed_req(DSPAD, DSP, nMREQ, nRFSH, AD, Bn2000) & csdd_req(DSPAD, DSP, nMREQ, nRFSH, AD, Bn2000) ) )  // gram access wait until blank
                    & ( nROMCS | ~(cnt <= 3'b001));     // during IPL ROM access, need 1clk wait.

    // nCSED, nCSDD
    // assert at DSPAD and DSP and BLANK status
    assign nCSED = ~BLANK | csed_req(DSPAD, DSP, nMREQ, nRFSH, AD, Bn2000);
    function csed_req(
        input dspad,
		  input dsp, 
		  input nmreq, 
		  input nrfsh, 
		  input [3:0]ad, 
		  input bn2   
    );
        begin
        if (bn2 == 1'b1)  // MZ-80b
            begin
             csed_req = ~( dsp & !nmreq & nrfsh & (dspad ? ( (ad == 4'h6) || (ad == 4'h7) ) 
																			: ( (ad == 4'hE) || (ad == 4'hF) ) ) );
            end else begin // MZ-2000
             csed_req = ~( dsp & !nmreq & nrfsh & !dspad & (ad >= 4'hC) );
            end
        
        end
    endfunction

    assign nCSDD = ~BLANK | csdd_req(DSPAD, DSP, nMREQ, nRFSH, AD, Bn2000);
    function csdd_req(
        input dspad, 
		  input dsp, 
		  input nmreq, 
		  input nrfsh, 
		  input [3:0]ad, 
		  input bn2   
    );
        begin
        if (bn2 == 1'b1)  // MZ-80b
            begin
             csdd_req = ~(dsp & !nmreq & nrfsh & (dspad ? (ad == 4'h5) 
                                                    : (ad == 4'hD) ) );             
            end else begin // MZ-2000
             csdd_req = ~( dsp & !nmreq & nrfsh & dspad & (ad == 4'hD) );
            end
        
        end
    endfunction


    // nROMCS
    // IPL status set acitive
    // if nROMCS is asserted, address access change 0x8000~0xFFFF to nRAS0 nRAS1(0x0000~0x7FFF)
    // not affect Bn2000
    assign nROMCS = ~(nMRAM & !nMREQ & !nRD & nRFSH & (AD[3] == 1'b0) );
	 
    // BUFGM, BUFG0
    // BUFGM is memory read or not, IOR status is not assert
    // BUFG0 is CPU RD or WD status, and intterrupt status is RD
    // not affect Bn2000
    assign BUFG0 = nRD & (nM1 | nIORQ);
    assign BUFGM = nRD | ~nIORQ;

endmodule

