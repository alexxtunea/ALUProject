module not1 (
    input in,
    output out
);
    assign out = ~in;
endmodule

module and3 (
    input in1, in2, in3,
    output out
);
    assign out = in1 & in2 & in3;
endmodule

module or4 (
    input in1, in2, in3, in4,
    output out
);
    assign out = in1 | in2 | in3 | in4;
endmodule

module mux4(
    input a, b, c, d,
    input [1:0] sel,
    output out
);
    wire nsel0, nsel1;
    wire w0, w1, w2, w3;

    not1 u1 (.in(sel[0]), .out(nsel0));
    not1 u2 (.in(sel[1]), .out(nsel1));

    and3 u3 (.in1(a), .in2(nsel1), .in3(nsel0), .out(w0));  // sel == 00
    and3 u4 (.in1(b), .in2(nsel1), .in3(sel[0]), .out(w1)); // sel == 01
    and3 u5 (.in1(c), .in2(sel[1]), .in3(nsel0), .out(w2)); // sel == 10
    and3 u6 (.in1(d), .in2(sel[1]), .in3(sel[0]), .out(w3)); // sel == 11


    or4 u7 (.in1(w0), .in2(w1), .in3(w2), .in4(w3), .out(out));
endmodule

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
endmodule

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