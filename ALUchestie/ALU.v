`include"Parallel_Adder.v"
`include"counter.v"
`include"control_unit.v"
`include"ushift.v"

module ALU(
	input clk, rst, start,
	input[1:0] sel,
	input[15:0] inbus, //am pus inbus pe 16 biti
	output wire[15:0] outbus,
	output finish
);

wire [7:0] A, Q, M;
wire sign, cnt7, cout;

wire[8:0]sum;
wire[14:0]c;

reg q_min1_reg, sign_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        sign_reg <= 1'b0;
        q_min1_reg <= 1'b0;
    end
    else begin
        // Logica combinatorie pentru a seta valoarea corect? a 'sign'
        if (c[2]) 
            sign_reg <= 1'b0;
        else if (c[8])
            q_min1_reg <= Q[0];  // Actualizezi q_min1_reg când c[7] este activ
	else if(c[4])
	     sign_reg<=sum[8];
    end
end

assign q_min1 = q_min1_reg;
assign sign = sign_reg;

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
	.y({sign,A} & {9{c[4]}} | {{sign,A} & {9{c[11]}}}), //am modificat aici sa faca adunarea cand e activ c4
	.cin(c[5]),
	.z(sum),
	.cout()
);

ushift #(.WIDTH(8)) reg_A(
	.clk(clk),
	.reset(rst),
	.sel({2{c[0]}} | {2{c[1]}} | {2{c[4]}} | {1'b0, c[8]} | {c[7], 1'b0} | {2{c[2]}}),
	.bsRight(A[7] & c[8]),
	.bsLeft(Q[7] & c[7]),
	.a(
		({8{c[0]}} & inbus[7:0]) |
		({8{c[4]}} & sum[7:0]) |
		({8{c[1]}} & 8'b00000000) |
		({8{c[2]}} & inbus[15:8])
	),
	.a_shifted(A)
);


ushift #(.WIDTH(8)) reg_Q(
	.clk(clk),
	.reset(rst),
	.sel({2{c[1]}} | {1'b0, c[8]} | {c[7], 1'b0} | {2{c[2]}} | {2{c[6]}}),
	.bsRight(A[0]),
	.bsLeft(1'b0), 
	.a(
		({8{c[1]}} & inbus[7:0]) | 
		({8{c[2]}} & inbus[7:0]) | 
		({8{c[6]}} & {Q[7:1], ~sign}) 
	),
	.a_shifted(Q)
);


ushift #(.WIDTH(8)) reg_M(
	.clk(clk),
	.reset(rst),
	//.clr(1'b0),
	//.ld(c[3]),
	.sel( ({2{c[3]}}) ),
	.bsRight(1'b0),
	.bsLeft(1'b0),
	.a(({8{c[3]}} & inbus[7:0])),
	.a_shifted(M)
);

ushift #(.WIDTH(16)) outbussy(
	.clk(clk),
	.reset(rst),
	//.clr(1'b0),
	//.ld(c[11]),
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
	wire finish;


ALU a(
	.clk(clk),
	.rst(rst),
	.start(start),
	.sel(sel),
	.inbus(inbus),
	.outbus(outbus),
	.finish(finish)
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
    for(i = 0; i < 152; i = i + 1) begin
        #10 clk = ~clk;
    end
end

// Reset scurt la început
initial begin
    #5  rst = 1;
    #15 rst = 0;
end

// Furnizam valorile de input si controlam "start"
initial begin
#20;
//adunare
start = 1; 
sel = 2'b00;
inbus = 8'd40; // A
#20;
start = 0;
#20;
inbus = 8'd12; // M
#70;
//scadere
rst=1;
start=0;
#10;
rst=0;
start = 1; 
sel = 2'b01;
inbus = 8'd40; // A
#20;
start = 0;
#20;
inbus = 8'd12; // M
#70;
//inmultire
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
//impartire
rst=1;
start=0;
#40;
rst=0;
start = 1; 
sel = 2'b11;
inbus = 16'd11542; // A.Q
#20;
start = 0;
#20;
inbus = 8'd135; // M
end

initial begin
    $display("Time\tclk\trst\tstart\tsel\tinbus\tsign\tA\tQ\tq_min1\tM\tc0\tc1\tc2\tc3\tc4\tc5\tc6\tc7\tc8\tc9\tc10\tc11\tc12\tc13\tc14\tcnt7\toutbus\tfinish");
    $monitor("%0t\t%b\t%b\t%b\t%02b\t%0d\t%b\t%0d\t%0d\t%b\t%0d\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%0d\t%0d\t%b", 
        $time, clk, rst, start, sel, inbus, 
        a.sign, a.A, a.Q, a.q_min1, a.M,
        a.c[0], a.c[1], a.c[2], a.c[3], a.c[4], a.c[5], a.c[6], a.c[7], a.c[8], a.c[9], a.c[10], a.c[11], a.c[12], a.c[13], a.c[14],
        a.cnt7, outbus, finish);
end


endmodule
