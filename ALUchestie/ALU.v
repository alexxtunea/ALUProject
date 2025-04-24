`include"Parallel_Adder.v"
`include"counter.v"
`include"control_unit.v"
`include"ushift.v"
`include"dff.v"

module ALU(
	input clk, rst, start,
	input[1:0] sel,
	input[15:0] inbus, 
	output wire[15:0] outbus,
	output finish, of_flag
);
    wire [7:0] A, Q, M;
    wire cnt7, cout, of_wire, q_min1, sign;
    wire [8:0] sum;
    wire [14:0] c;

    // Flip-flopuri pentru retinerea sign si q_min1
    dff dff_sign(
        .clk(clk),
        .reset(rst),
        .d((c[2] & 1'b0) | 
           (c[4] & sum[8]) | 
           (~(c[2] | c[4]) & sign)),
        .q(sign)
    );

    dff dff_q_min1(
        .clk(clk),
        .reset(rst),
        .d((c[8] & Q[0]) | 
           (~c[8] & q_min1)),
        .q(q_min1)
    );

    counter contor(
	.clk(clk),
	.rst(rst),
	.c8(c[7]),
	.c9(c[10]),
	.cnt7(cnt7)
);

    control_unit unitate(
	.clk(clk),
	.rst(rst),
	.start(start),
	.sel(sel),
	.q_0(Q[0]),
	.q_min1(q_min1),
	.sign(sign),
	.cnt7(cnt7),
	.c(c),
	.finish(finish)
);

Parallel_Adder adder(
	.x({1'b0|c[5],M^{8{c[5]}}}),
	.y({sign,A} & {9{c[4]}} | {{sign,A} & {9{c[11]}}}), 
	.cin(c[5]),                                              
	.z(sum),
	.cout(),
	.oflow(of_wire)
);

assign of_flag = of_wire & ~(sel[1]) & c[4];

ushift #(.WIDTH(8)) reg_A(
	.clk(clk),
	.reset(rst),
	.sel({2{c[0]}} | {2{c[1]}} | {2{c[4]}} | {1'b0, c[8]} | {c[9], 1'b0} | {2{c[2]}} | {2{c[11]}}),   //sa se incarce in A si cand e c[11]
	.bsRight(A[7] & c[8]),
	.bsLeft(Q[7] & c[9]),
	.a(
		({8{c[0]}} & inbus[7:0]) |
		({8{c[4]}} & sum[7:0]) |
		({8{c[1]}} & 8'b00000000) |
		({8{c[2]}} & inbus[14:7]) |
		({8{c[11]}} & sum[7:0])     //rand adaugat pentru c[11]
	),
	.a_shifted(A)
);


ushift #(.WIDTH(8)) reg_Q(
	.clk(clk),
	.reset(rst),
	.sel({2{c[1]}} | {1'b0, c[8]} | {c[9], 1'b0} | {2{c[2]}} | {2{c[6]}}),
	.bsRight(A[0]),
	.bsLeft(1'b0), 
	.a(
		({8{c[1]}} & inbus[7:0]) | 
		({8{c[2]}} & {inbus[6:0], 1'b0}) | 
		({8{c[6]}} & {Q[7:1], ~sign}) 
	),
	.a_shifted(Q)
);


ushift #(.WIDTH(8)) reg_M(
	.clk(clk),
	.reset(rst),
	.sel( ({2{c[3]}}) ),
	.bsRight(1'b0),
	.bsLeft(1'b0),
	.a(({8{c[3]}} & inbus[7:0])),
	.a_shifted(M)
);

ushift #(.WIDTH(16)) outbussy(
	.clk(clk),
	.reset(rst),
	.sel( ({2{c[12]}}) | ({2{c[13]}}) | ({2{c[14]}}) ),
	.bsRight(1'b0),
	.bsLeft(1'b0),
	.a({{8{1'b0}}, {8{c[12]}} & A} | {{{8{c[13]}} & A}, {8{c[13]}} & Q} | {{8{1'b0}}, {8{c[14]}} & Q}),
	.a_shifted(outbus)
);
	
endmodule

module ALU_tb;
	reg clk, rst, start;
	reg[1:0] sel;
	reg[15:0] inbus;
	wire[15:0] outbus;
	wire finish, of_flag;


ALU a(
	.clk(clk),
	.rst(rst),
	.start(start),
	.sel(sel),
	.inbus(inbus),
	.outbus(outbus),
	.finish(finish),
	.of_flag(of_flag)
);


initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        clk=0;
        rst=0;
        start=0;
        sel=2'b00;
        inbus=0;
    end


integer i;
initial begin
    for(i = 0; i < 300; i = i + 1) begin
        #10 clk = ~clk;
    end
end

// Reset scurt la început
initial begin
    #5  rst = 1;
    #15 rst = 0;
end

initial begin
#20;
//Adunare fara overflow 
start = 1; 
sel = 2'b00;
inbus = 8'd20; // A = 20
#20;
start = 0;
#20;
inbus = 8'd75; // M = 75
#70;
//Adunare cu overflow 
rst=1;
start=0;
#10;
rst=0;
start = 1; 
sel = 2'b00;
inbus = 8'b01111111; // A = 127
#20;
start = 0;
#20;
inbus = 8'b01111110; // M = 126 
#70;
//Se va activa flagul de overflow, iar rezultatul va fi -3 in C2 adica 1111 1101

//Scadere fara overflow
rst=1;
start=0;
#10;
rst=0;
start = 1; 
sel = 2'b01;
inbus = 8'd178; // A = 178
#20;
start = 0;
#20;
inbus = 8'd34; // M = 34
#70;

//Scadere cu overflow
rst=1;
start=0;
#10;
rst=0;
start = 1; 
sel = 2'b01;
inbus = 8'b10000000; // A = -128 in C2
#20;
start = 0;
#20;
inbus = 8'b00000001; // M = 1 in C2
#70;
//Se va activa flagul de overflow, iar rezultatul va fi 127 in C2. Fiind un nr pozitiv, se va afisa corect in transcript

//Inmultire cu numere pozitive 
rst=1;
start=0;
#40;
rst=0;
start = 1; 
sel = 2'b10;
inbus = 8'd40; // Q
#20;
start = 0;
#20;
inbus = 8'd12; // M
#500

//Inmultire cu numere negative 
rst=1;
start=0;
#40;
rst=0;
start = 1; 
sel = 2'b10;
inbus = 8'b11100111; // Q = -25 in C2
#20;
start = 0;
#20;
inbus = 8'b11010110; // M = -42 in C2
#500
//-25 * -42 = 1050 

//Inmultire cu un numar negativ si unul pozitiv 
rst=1;
start=0;
#40;
rst=0;
start = 1; 
sel = 2'b10;
inbus = 8'b11101001; // Q = -23 in C2
#20;
start = 0;
#20;
inbus = 8'b01001011; // M = 75 in C2
#500
//-23 * 75 = -1725 care in C2 este 1111 1001 0100 0011  
//Pe outbus fiind perceput ce unsigned se va afisa 63811


//Impartire
rst=1;
start=0;
#40;
rst=0;
start = 1; 
sel = 2'b11;
inbus = 16'd5771; // A.Q  
#20;
start = 0;
#20;
inbus = 8'd125; // M

end

//5771 : 135 = 42 rest 101
initial begin
    $display("Time\tclk\trst\tstart\tsel\tinbus\tsign\tA\tQ\tq_min1\tM\toutbus\t\toutbus_dec\t\tof\tfinish\cnt\c11");
    $monitor("%0t\t%b\t%b\t%b\t%02b\t%0d\t%b\t%0d\t%0d\t%b\t%0d\t%016b\t%0d\t\t\t%b\t%b\t%b\t%b", 
        $time, clk, rst, start, sel, inbus, 
        a.sign, a.A, a.Q, a.q_min1, a.M, outbus, outbus, of_flag, finish, a.cnt7, a.c[11]);
end
endmodule