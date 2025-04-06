`include"Parallel_Adder.v"
`include"counter.v"
`include"control_unit.v"
`include"rgst.v"

module ALU(
	input clk, rst, start,
	input[1:0] sel,
	input[7:0] inbus,
	output wire[7:0] outbus,
	output finish
);

wire [7:0] A, Q, M;
wire q_min1, sign, cnt7;

wire[8:0]sum;
wire[12:0]c;

counter contor(
	.clk(clk),
	.rst(rst),
	.c8(c[8]),
	.c9(c[9]),
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
	.x({1'b0,M^{8{c[5]}}}),
	.y({sign,A}),
	.cin(c[5]),
	.z(sum),
	.cout()
);

rgst reg_A(
	.clk(clk),
	.rst(rst),
	.clr(1'b0),
	.ld(c[0] | c[4]),
	.d(((({8{c[0]}} & inbus[7:0]) | ({8{c[4]}} & sum[7:0])))),
	.q(A)
);

rgst reg_M(
	.clk(clk),
	.rst(rst),
	.clr(1'b0),
	.ld(c[3]),
	.d(({8{c[3]}} & inbus[7:0])),
	.q(M)
);

rgst outbussy(
	.clk(clk),
	.rst(rst),
	.clr(1'b0),
	.ld(c[11]),
	.d(A & {8{c[11]}}),
	.q(outbus)
);

assign sign = 1'b0;
assign q_0 = 1'b0;
assign q_min1 = 1'b0;
assign cnt7 = 1'b0;

/*always @(posedge clk or posedge rst) begin
        if (rst) begin
            A <= 8'd0;
            M <= 8'd0;
            Q <= 8'd0;
            outbus <= 16'd0;
        end else begin
            A <= ((({8{c[0]}} & inbus[7:0]) | ({8{c[4]}} & sum)));
            M <= ({8{c[3]}} & inbus[7:0]);
            outbus <= ({{8{1'b0}}, {A & {8{c[11]}}}});
	end
    end
endmodule
*/
endmodule

module ALU_tb;
	reg clk, rst, start;
	reg[1:0] sel;
	reg[7:0] inbus;
	wire[7:0] outbus;
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
    for(i = 0; i < 24; i = i + 1) begin
        #10 clk = ~clk;
    end
end

// Reset scurt la început
initial begin
    #5  rst = 1;
    #15 rst = 0;
end

// Furniz?m valorile de input ?i control?m "start"
initial begin
#20;
start = 1; 
sel = 2'b00;
inbus = 8'd40; // A
#20;
start = 0;
#20;
inbus = 8'd12; // M
#70;
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
end

// Monitor pentru afi?are
initial begin
    $display("Time\tclk\trst\tstart\tsel\tinbus\tA\tM\tsum\tc0\tc3\tc4\tc5\tc11\toutbus\tfinish");
    $monitor("%0t\t%b\t%b\t%b\t%02b\t%0d\t%d\t%d\t%b\t%b\t%b\t%b\t%b\t%b\t%0d\t%b", 
        $time, clk, rst, start, sel, inbus, 
        a.A, a.M, a.sum,
        a.c[0], a.c[3], a.c[4], a.c[5], a.c[11], 
        outbus, finish);
end
endmodule
