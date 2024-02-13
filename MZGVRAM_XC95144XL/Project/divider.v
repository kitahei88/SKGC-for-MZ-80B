`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:10:32 05/24/2022 
// Design Name: 
// Module Name:    divider 
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
module divider(
input clk,
input rst,
output reg out
);

reg[2:0]c;

always@(posedge clk or posedge rst)begin
    if(rst)begin
        out <= 0;
        c <= 3'd0;
    end else begin
        c <= c + 3'd1;
        if(c == 3'd5)begin
            c <= 3'd0;
            out <= ~out;
        end
    end
end
endmodule

