`default_nettype none
/*
    counter for cnt 
    CLK = 16MHz
*/
module mkcnt
(
    input CLK,
    input RST,
//    input nHBLANK,
//    input nVBLANK,
    input BLANK,
    output reg [2:0]CNT
);
//    reg [2:0]CNT; 

    always @(posedge CLK or posedge RST ) begin
        if (RST) begin
            CNT <= 3'b000;
        end  else if (BLANK) begin
				CNT <= 3'b000;
		  end else begin // CLK rise
            CNT <= CNT + 3'b001;
        end
    end
endmodule
