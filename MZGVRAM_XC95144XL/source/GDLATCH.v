`default_nettype none
/*
    Graphic data latch 
    CLK = 16MHz
*/
module gdlatch
(
    input CLK,
    input RST,
	 input BLANK,
//    input nHBLANK,
//    input nVBLANK,
    input [7:0]DB,
    input [2:0]cnt,
    output reg [7:0]ROD,
    output reg [7:0]GOD,
    output reg [7:0]BOD
);

//    reg [7:0]ROD;
//    reg [7:0]GOD;
//    reg [7:0]BOD;

//    always @(posedge CLK or posedge RST) begin
	 always @(negedge CLK or posedge RST) begin  // 31ns delay
//        if (RST | !nVBLANK | !nHBLANK ) begin
        if (RST) begin            
            ROD <= 8'b0;
            GOD <= 8'b0;
				BOD <= 8'b0;                        
        end else if (!BLANK) begin
//        end else if (nHBLANK) begin
//        end else begin
				if (cnt == 3'b010) begin
					ROD <= DB;
				end else if (cnt == 3'b100) begin
					GOD <= DB;            
				end else if (cnt == 3'b110) begin
					BOD <= DB;
				end
			end
    end
endmodule
