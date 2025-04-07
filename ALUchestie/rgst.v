module mux4 (
    input [1:0] sel,
    input a, b, c, d,
    output out
);
    assign out = (sel == 2'b00) ? a :
                 (sel == 2'b01) ? b :
                 (sel == 2'b10) ? c :
                                  d;
endmodule

/*
module mux4_tb;
    reg        a, b, c, d;
    reg [1:0]  sel;
    wire       out;
    mux4 dut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sel(sel),
        .out(out)
    );
    integer k;
    initial begin
        $display(" a  b  c  d | sel | out ");
	$monitor(" %b  %b  %b  %b | %02b  |  %b", a, b, c, d, sel, out);
        for (k = 0; k < 16; k = k + 1) begin
            {d, c, b, a} = $urandom(); 
            sel = $urandom();        
            #10; 
        end
    end
endmodule*/

module d_ff(
  input clk,rst,d,
  output reg q
);
  always @ (posedge clk or posedge rst)        
    if (rst)      q<=0;
    else          q<=d;
endmodule

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