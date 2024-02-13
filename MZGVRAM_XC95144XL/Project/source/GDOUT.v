`default_nettype none
/*
    Graphic data out from data
    CLK = 16MHz
*/
module gdout(
    input CLK,
    input RST,
//	 input BLANK,
    input nHBLANK,
    input nVBLANK,
    input [7:0]DATA,
    input [2:0]cnt,
    output GDAT
);
 //   reg [2:0]cnt; 
    reg [7:0] outdata;

//    assign GDAT = ( (!nHBLANK | !nVBLANK ) ? 1'b0 : outdata[7]);
    assign GDAT = outdata[0];
    
    always @(posedge CLK or posedge RST) begin
//    always @(negedge CLK or posedge RST) begin	 
        if (RST) begin
            outdata <= 8'h0;
        end else if ( !nHBLANK | !nVBLANK ) begin
            outdata <= 8'h0;
        end else if (cnt == 3'b000) begin
            outdata <= DATA;
        end else begin
            outdata <= (outdata >> 1);
        end
    end
endmodule
