module rgst (
    input clk, rst, ld, clr,
    input [7:0] d, 
    output reg [7:0] q
);
    always @ (posedge clk, posedge rst)
        if (rst)                 q <= 0;
        else if (clr)               q <= 0;
        else if (ld)                q <= d;
endmodule