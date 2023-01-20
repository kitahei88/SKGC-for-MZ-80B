`default_nettype none
/*
    Make sync signal from blank signal
    CLK = 16MHz
*/

module mksync #(parameter con = 0, parameter coff = 1)
(   input CLK,
    input RST,
    input nBLANK,
    output reg nSYNC
);
//    reg nSYNC;
//    integer counter;
    reg [12:0]counter;
	 
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            counter <= 13'd0;
            nSYNC  <= 1'b1;
        end else if (!nBLANK) begin
            counter <= counter + 13'd1;
            if ((counter > con) && (counter < coff)) begin
                nSYNC <= 1'b0;
            end else begin
                nSYNC <= 1'b1;      
            end
        end else begin
            counter <= 13'd0;
            nSYNC <= 1'b1;
        end
    end
endmodule
 