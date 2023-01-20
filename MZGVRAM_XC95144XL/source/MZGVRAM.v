`default_nettype none
/*  
    GVRAM board fro MZ-80B to MZ-2000  
    topmodule
    2022.03.21 kitahei88, Takuya Fukuda
    16MHz  1clk = 62.5ns
	 48MHz/4 = 12MHz 1clk = 83.333ns
	ok 50MHz/4 = 12.5Mhz 1clk = 80ns
	50MHz/16 = 3.125MHz 1clk = 320 ns
	50Mhz 1clk = 20ns
*/
//`include "MKSYNC.v"
`include "GDOUT.v"
`include "GDLATCHAD.v"
`include "GDLATCH.v"
`include "MKCNT.v"
//`include "divider.v"

 module MZGVRAM 
 #(
    parameter [1:0] F4=2'b00,
    parameter [1:0] F5=2'b01,
    parameter [1:0] F6=2'b10,
    parameter [1:0] F7=2'b11
/*	 
//   parameter [15:0] HSYNCON = 16'b00000000_01111111,  // 127start delay 8us (from actual mesurements)
    parameter [12:0] HSYNCON = 13'd25,  // 25 start delay 8us (from actual mesurements) for 50M/16
//    parameter [15:0] HSYNCOFF =16'b00000000_11001010,  // 202 end at 8 +4.7 us (from actual mesurements)
    parameter [12:0] HSYNCOFF =13'd40,  // 40 end at 8 +4.7 us (from actual mesurements) for 50M/16
//    parameter [15:0] VSYNCON = 16'b01000100_11000000,  // 17600 start delay 1.1ms (from actual mesurements)
    parameter [12:0] VSYNCON = 13'd3437,  // 3437 start delay 1.1ms (from actual mesurements) 50M/16
//    parameter [15:0] VSYNCOFF =16'b10000011_01000000  // 33600  end at 1.1+1ms (from actual mesurements)
    parameter [12:0] VSYNCOFF =13'd6562  // 6562  end at 1.1+1ms (from actual mesurements) 50M/16	 
*/
 )
 (
    input CLK,          // 50MHz clk from MZ-80B
    input RST,          // Reset signal from MZ-80B
    input nHBLANK, nVBLANK, BLANK,  
    input VQH,VID,VGATE,    // VQH is CGdata , VID is inversion B/W(L), VGATE is force display to blank(H, always L)
    input nCSED,nF47,nIWR,
//	 input nCSED,nIOW,
    input nRD,nWD,	//nMREQ,
 //   input [7:0] RGDB,
 //   input [7:0] GGDB,
//    input [7:0] BGDB,
    input [7:0]DB,    
    input [1:0]IOAD,
    input [3:0]IODB,

    output [13:0]SRAD,
//    output [2:0]SBANKAD, // high bit is reserved to set 0,
    output [1:0]SBANKAD, // high bit is reserved to set 0,
    output nOE,
    output nWE,
	 output nCS,
    output BUFDIR,nBUFOE,
 //   input Bn2000,
 //   output [1:0] GSELAD,
    output RED,GREEN,BLUE,
//    output nHSYNC,nVSYNC,
    output GOUT,
//    output nSOE,nSWE,
//    input SW,nMRAM,

	 
	 output tp1,tp2
);

//    assign Bn2000 = SW | nMRAM;
// for IO access

    wire nIOW;
    assign nIOW = nF47 | nIWR;
    reg [3:0] f4,f5,f6,f7;
	 reg rstchk;
    wire [7:0] RD,GD,BD; // next gram data
    wire [13:0] OUTAD;
    wire RG,GG,BG;
    wire [2:0]cnt;
	 wire NBLANK;
	 assign NBLANK = ~(nHBLANK & nVBLANK);
	 reg rCSED;
	 
//	 wire CLK8;
	 
//	 reg we;
//	reg [2:0]wecnt;
	reg [2:0]iocnt;
	reg [2:0]csedcnt;
	
//  ***  assign nBUFOE = (( !nMREQ && BLANK && !nCSED && |f7[1:0] ) ? 1'b0 : 1'b1);

//    assign nBUFOE = (( !nMREQ && BLANK && !nCSED && |f7[1:0] && (nWD ^ nRD) ) ? 1'b0 : 1'b1);
//    assign nBUFOE = ((!nCSED && |f7[1:0] && (nWD ^ nRD) ) ? 1'b0 : 1'b1); 
//    assign nBUFOE = ((NBLANK && !nCSED && |f7[1:0] && (nWD ^ nRD) ) ? 1'b0 : 1'b1); 
    assign nBUFOE = ((NBLANK && !rCSED && |f7[1:0] && (nWD ^ nRD) ) ? 1'b0 : 1'b1); 

//    assign nBUFOE = ((NBLANK && !nCSED && |f7[1:0] && !nWD ) ? 1'b0 : 1'b1); 		 

//    assign nBUFOE = (( (!nCSED && |f7[1:0] && !nRD) || !we ) ? 1'b0 : 1'b1); 	 

//    assign BUFDIR = ~nWD & nRD ; // WD 1 : A to B, RD 0 : B to A 74AHCT245
//   assign BUFDIR = nRD ; // WD 1 : A to B, RD 0 : B to A 74AHCT245
    assign BUFDIR = ~nWD ; // WD 1 : A to B, RD 0 : B to A 74AHCT245

//	 assign nOE = (NBLANK ? ( (!nBUFOE && !BUFDIR ) ? 1'b0 : 1'b1) : 1'b0);
	 assign nOE = ( !nBUFOE ? BUFDIR : 1'b0) ;
//	 assign nOE = 1'b0;

//  ***  assign nOE = ( (nCSED || nWD) ? 1'b0 : 1'b1);

//	 assign nWE = ( ( !nMREQ && BLANK && !nCSED && !nWD && nRD && |f7[1:0] ) ? 1'b0 : 1'b1);
//    assign nWE = ( ( !nMREQ && !nCSED && !nWD && nRD && |f7[1:0] ) ? 1'b0 : 1'b1);
//    assign nWE = ( (!nBUFOE && BUFDIR) ? 1'b0 : 1'b1);
//	 assign nWE = ~(BLANK ? ( (!nBUFOE && !nWD) ? 1'b0 : 1'b1) : 1'b1);	
	 assign nWE = ( !nBUFOE ? !BUFDIR : 1'b1);	
//	 assign nWE = ~(BLANK ? we : 1'b1);	 

 //   assign nRSWE = ( ( !nMREQ && BLANK && !nCSED && (f7[1:0] == 2'b10) && !nWD && nRD ) ? 1'b0 : 1'b1);
 //   assign nGSWE = ( ( !nMREQ && BLANK && !nCSED && (f7[1:0] == 2'b11) && !nWD && nRD ) ? 1'b0 : 1'b1);  
 //   assign nBSWE = ( ( !nMREQ && BLANK && !nCSED && (f7[1:0] == 2'b01) && !nWD && nRD ) ? 1'b0 : 1'b1);

	 assign nCS = (nBUFOE & ~((cnt == 3'b010) | (cnt == 3'b100) | (cnt == 3'b110)) );
//	 assign nCS = ~(BLANK ? ~(!nCSED && |f7[1:0]) : ~((cnt == 3'b010) | (cnt == 3'b100) | (cnt == 3'b110)) );	 
//	assign nCS = 1'b0;

//   assign SRAD = ( !nWE ? 14'bz : OUTAD );
//    assign SRAD = ( (!nMREQ && !nCSED) ? 14'bz : OUTAD );
//    assign SRAD = ( !nBUFOE ? 14'bz : OUTAD );
    assign SRAD = ( NBLANK ? 14'bz : OUTAD );

//	 assign SBANKAD = (BLANK ? {1'b0 , f7[1:0]} :
//  assign SBANKAD = ( (!nMREQ && !nCSED) ? {1'b0 , f7[1:0]} :

//	 assign SBANKAD = ( !nBUFOE ?  f7[1:0] : 
	 assign SBANKAD = ( NBLANK ?  f7[1:0] :  
//                              (cnt == 3'b001 | cnt == 3'b010) ? 2'b10 : // red
                              (cnt == 3'b010) ? 2'b10 : // red
//                              (cnt == 3'b011) ? 2'b10 : // red										
//                              (cnt == 3'b011 | cnt == 3'b100) ? 2'b11 : // green
                              (cnt == 3'b100) ? 2'b11 : // green
//                              (cnt == 3'b101 | cnt == 3'b110) ? 2'b01 : // blue										
//                              (cnt == 3'b101) ? 2'b01 : // blue
                              (cnt == 3'b110) ? 2'b01 : // blue
											2'bzz );  // other
											
 //   assign RD = (BLANK ? 8'b0 : RGDB);
 //   assign GD = (BLANK ? 8'b0 : GGDB);
 //   assign BD = (BLANK ? 8'b0 : BGDB);
 // TODO: CG overlap 
//    assign RED   = 0;
//	 assign RED   = ( (!nHBLANK | !nVBLANK | VGATE | ~VID) ? 1'b0 : (RG & f6[1] & (f5[3]|~((f5[2]|f5[0])&VQH))) | f4[1] | (VQH & f5[1] & ~(f5[3]&(GG|BG))) );
	 assign RED   = ( (!nHBLANK | !nVBLANK | VGATE | ~VID) ? 1'b0 : 
																				f5[3] ?  ( (RG & f6[1]) ? 1'b1	: ((VQH &f5[1]) | f4[1]) ) :
																							( VQH 			? f5[1]	: ((RG & f6[1]) | f4[1]) ) 
																							);
//    assign GREEN = 0;
//	 assign GREEN = ( (!nHBLANK | !nVBLANK | VGATE | ~VID) ? 1'b0 : (GG & f6[2] & (f5[3]|~((f5[1]|f5[0])&VQH))) | f4[2] | (VQH & f5[2] & ~(f5[3]&(RG|BG))) );
	 assign GREEN = ( (!nHBLANK | !nVBLANK | VGATE | ~VID) ? 1'b0 :
																				f5[3] ?  ( (GG & f6[2]) ? 1'b1	: ((VQH &f5[2]) | f4[2]) ) :
																							( VQH 			? f5[2]	: ((GG & f6[2]) | f4[2]) ) 
																							);

//    assign BLUE  = ( (!nHBLANK | !nVBLANK | VGATE | ~VID) ? 1'b0 : (BG & f6[0] & (f5[3]|~((f5[2]|f5[1])&VQH))) | f4[0] | (VQH & f5[0] & ~(f5[3]&(RG|GG))) );
    assign BLUE  = ( (!nHBLANK | !nVBLANK | VGATE | ~VID) ? 1'b0 :
	 																			f5[3] ?  ( (BG & f6[0]) ? 1'b1	: ((VQH &f5[0]) | f4[0]) ) :
																							( VQH 			? f5[0]	: ((BG & f6[0]) | f4[0]) ) 
																							);
																							
//    assign BLUE  = ( (!nHBLANK | !nVBLANK ) ? 1'b0 : BG );	 
    assign GOUT  = ( (!nHBLANK | !nVBLANK | VGATE | f6[3]) ? 1'b0 : ( (RG & f6[1]) | (GG & f6[2]) | (BG & f6[0]) ) );
//	 assign GOUT  = 0;
//
	 assign tp1 = rstchk;
//	 assign tp1 = (!nIOW & (IOAD == F6));  // 	ED78
	 assign tp2 = (!BLANK | nRD | nCSED) ;
//	 assign tp2 = (|f6[2:0]);		// 51 toka A1 toka ?

// nWE delay 
//    always @(posedge CLK or posedge RST) begin
//        if (RST) begin
//            wecnt <= 3'b0;
//            we  <= 1'b1;
////        end else if (!nBUFOE && !nWD) begin
//        end else if ((!nCSED && |f7[1:0]) && !nWD) begin
//				wecnt <= wecnt + 3'b001;
//					if (wecnt == 3'b001) begin // delay 1 clk 62.5ns
//					we <= 1'b0;
//					end else if (wecnt == 3'b010) begin // end at 187.5ns( 125ns L)
//					we <= 1'b1;
//					wecnt <= 3'b001;
//					end 
//		  end else begin
//		  		we <= 1'b1;
//				wecnt <= 3'b0;
//			end
//    end
// IO access 
//    always @(posedge nIOW or posedge RST) begin
//        if (RST) begin
//            f4  <= 4'h0;
//            f5  <= 4'b0111;	// 07
//            f6  <= 4'b1000;	// 08
//            f7  <= 4'h0;
//				iocnt <= 3'b0;
//        end else if (nIOW) begin
//					case (IOAD)
//						F4 : f4 <= IODB;
//						F5 : f5 <= IODB;
//						F6 : f6 <= IODB;
//						F7 : f7 <= IODB; 
//						default: ;	
//					endcase
//			end 	
//    end

// CSED delay 
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            rCSED <= 1'b1;
				csedcnt <= 3'b0;
        end else if (!nCSED) begin
				csedcnt <= csedcnt + 3'b001;
				if (csedcnt == 3'b011) begin
					rCSED <= 1'b0;
					csedcnt <= 3'b010;
				end
			end else begin
				 	csedcnt <= 3'b0;
					rCSED <= 1'b1;
			end	
    end
	 
// IO access 
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            f4  <= 4'h0;
            f5  <= 4'b0111;	// 07
            f6  <= 4'b1000;	// 08
            f7  <= 4'h0;
				iocnt <= 3'b0;
				rstchk <= 1'b1;
        end else if (!nIOW) begin
				rstchk <= 1'b0;
				iocnt <= iocnt + 3'b001;
				if (iocnt == 3'b011) begin
					case (IOAD)
						F4 : f4 <= IODB;
						F5 : f5 <= IODB;
						F6 : f6 <= IODB;
						F7 : f7 <= IODB; 
						default: ;	
					endcase
				end else if (iocnt == 3'b101) begin
					iocnt <= 3'b100;
				end 
			end else begin
				 	iocnt <= 3'b0;
			end	
    end
	 
// clock divider
//	 divider divider8 (CLK,RST,CLK8);
//	 divider divider16 (CLK4,RST,CLK16);
	 
// Hsync and Vsync    
//   mksync #(HSYNCON, HSYNCOFF) hsync (CLK16,RST,nHBLANK,nHSYNC);
//    mksync #(VSYNCON, VSYNCOFF) vsync (CLK16,RST,nVBLANK,nVSYNC);

// 
    mkcnt mkcnt (CLK,RST,NBLANK,cnt);

    gdlatchad gdlatchad (CLK,RST,nHBLANK,nVBLANK,OUTAD,cnt);
//    gdlatchad gdlatchad (CLK8,RST,nHBLANK,nVBLANK,OUTAD);
    gdlatch gdlatch(CLK,RST,NBLANK,DB,cnt,RD,GD,BD);
//    gdlatch gdlatch(CLK,RST,nHBLANK,DB,cnt,RD,GD,BD);
    gdout rgdout(CLK,RST,nHBLANK,nVBLANK,RD,cnt,RG);
    gdout ggdout(CLK,RST,nHBLANK,nVBLANK,GD,cnt,GG);
    gdout bgdout(CLK,RST,nHBLANK,nVBLANK,BD,cnt,BG);
endmodule

