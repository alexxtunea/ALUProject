module xor2(input a, input b, output out);
    assign out = a ^ b;
endmodule

module and2(input a, input b, output out);
    assign out = a & b;
endmodule

module or3(input a, input b, input c, output out);
    assign out = a | b | c;
endmodule

module fac(
    input x, y, cin,
    output z, cout
);
    wire xy, xcin, ycin;
    wire temp1;

    xor2 u1 (.a(x), .b(y), .out(temp1));
    xor2 u2 (.a(temp1), .b(cin), .out(z));

    and2 u3 (.a(x), .b(y), .out(xy));
    and2 u4 (.a(x), .b(cin), .out(xcin));
    and2 u5 (.a(y), .b(cin), .out(ycin));

    or3 u6 (.a(xy), .b(xcin), .c(ycin), .out(cout));
endmodule

module Parallel_Adder(
    input [8:0] x, y,
    input cin,
    output [8:0] z,
    output cout
);
    wire [7:0] carry;

    fac fa0 (.x(x[0]), .y(y[0]), .cin(cin),        .z(z[0]), .cout(carry[0]));
    fac fa1 (.x(x[1]), .y(y[1]), .cin(carry[0]),   .z(z[1]), .cout(carry[1]));
    fac fa2 (.x(x[2]), .y(y[2]), .cin(carry[1]),   .z(z[2]), .cout(carry[2]));
    fac fa3 (.x(x[3]), .y(y[3]), .cin(carry[2]),   .z(z[3]), .cout(carry[3]));
    fac fa4 (.x(x[4]), .y(y[4]), .cin(carry[3]),   .z(z[4]), .cout(carry[4]));
    fac fa5 (.x(x[5]), .y(y[5]), .cin(carry[4]),   .z(z[5]), .cout(carry[5]));
    fac fa6 (.x(x[6]), .y(y[6]), .cin(carry[5]),   .z(z[6]), .cout(carry[6]));
    fac fa7 (.x(x[7]), .y(y[7]), .cin(carry[6]),   .z(z[7]), .cout(carry[7]));
    fac fa8 (.x(x[8]), .y(y[8]), .cin(carry[7]),   .z(z[8]), .cout(cout));
endmodule

module Parallel_Adder_tb;
    reg [8:0] x, y;
    reg cin;
    wire [8:0] z;
    wire cout;

    Parallel_Adder uut (
        .x(x),
        .y(y),
        .cin(cin),
        .z(z),
        .cout(cout)
    );
    integer k;
    initial begin
        $display("Time\tx\t     y\t   cin\tcout\t\tz");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b", $time, x, y, cin, cout, z);
        for (k = 0; k < 512; k = k + 1) begin
            {x, y, cin} = {$random} % (2**19); // random 9+9+1 bits
            #10;
        end
    end
endmodule
