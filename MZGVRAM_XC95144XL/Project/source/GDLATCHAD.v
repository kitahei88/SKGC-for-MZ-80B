`default_nettype none
/*
    Graphic data address latch 
    CLK = 16MHz
*/
module gdlatchad
(
    input CLK,
    input RST,
    input nHBLANK,
    input nVBLANK,
//    input [7:0]DB,
    output reg [13:0]OUTAD,

    input [2:0]CNT

//	 output reg tp
//    output [7:0]DAT
);

    reg [9:0]LIMITAD; 
//    reg [13:0]OUTAD;
 //   reg [7:0]DAT;
//	 assign OUTAD = OUTAD;

    always @(posedge CLK or posedge RST) begin
//    always @(negedge CLK or posedge RST) begin
        if (RST) begin
//				tp <= 1'b0;
//            OUTAD <= 14'b00000000000000;
					OUTAD <= 14'b0;
        end else if (!nVBLANK) begin
//            OUTAD <= 14'b00000000000000;
					OUTAD <= 14'b0;
//				tp <= 1'b0;				
		  end else if ( (CNT == 3'b000) && nHBLANK && (OUTAD < {LIMITAD,4'b0000}) ) begin
//		  end else if (nHBLANK && (OUTAD < {LIMITAD,4'b0000}) ) begin

				if (OUTAD == 14'b11111001111111) begin	// FE7F
					OUTAD <= 14'b0;
				end else begin 				
					OUTAD <= OUTAD + 14'b00000000000001;
				end 
//        end else if (OUTAD > {LIMITAD,4'b0000}) begin
//				tp <= 1'b1;
		  end
    end
	 
    always @(negedge nHBLANK or posedge RST) begin
        if (RST) begin
            LIMITAD <= 10'b0000000101;	// 50h
        end else if (!nVBLANK) begin
            LIMITAD <= 10'b0000000101;		 
        end else begin
            LIMITAD <= LIMITAD + 10'b0000000101; // inc 80 bytes
        end 
    end
	 
endmodule
