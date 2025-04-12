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
wire sign, cnt7;

wire[8:0]sum;
wire[12:0]c;

reg q_min1_reg, sign_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        q_min1_reg <= 1'b0;
	sign_reg <= 1'b0;	
    end
    else if(c[2])
	sign_reg <= 1'b0;
    else if(c[6])  //folosim c[6] ca sa facem LSHIFT A.Q
	sign_reg <= A[7];
    else if (c[7]) // presupunem ca c[7] controleaza update-ul lui q_min1
        q_min1_reg <= Q[0];
	
end

assign q_min1 = q_min1_reg;
assign sign = sign_reg;

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
	.y({sign,A} & {9{c[4]}} | {{sign,A} & {9{c[10]}}}), //am modificat aici sa faca adunarea cand e activ c4
	.cin(c[5]),
	.z(sum),
	.cout()
);

ushift #(.WIDTH(8)) reg_A(
	.clk(clk),
	.reset(rst),
	//.clr(1'b0),
	//.ld(c[0] | c[1] |  c[4] | c[7]),
	.sel({2{c[0]}} | {2{c[1]}} | {2{c[4]}} | {1'b0,{c[7]}} | {{c[6]}, 1'b0} | {2{c[2]}}),//same here pt lshift-ul de la impartire 
	.bsRight(A[7] & c[7]),  //am adaugat semnalul de control
	.bsLeft(Q[7] & c[6]),        
	.a( ({8{c[0]}} & inbus[7:0]) | ({8{c[4]}} & sum[7:0]) | ({8{c[1]}} & 8'b00000000) | ({8{c[7]}} & A) | ({8{c[2]}} & inbus[15:8])), //aici am facut incarcarea  lui A de pe cei 8 MSB de la inbus
	.a_shifted(A)
);

ushift #(.WIDTH(8)) reg_Q(
	.clk(clk),
	.reset(rst),
	//.clr(1'b0),
	//.ld(c[1] | c[7]),
	.sel({2{c[1]}} | {1'b0,{c[7]}} | {{c[6]}, 1'b0} | {2{c[2]}}),
	.bsRight(A[0]),
	.bsLeft(1'b0 | (~(sign) & c[6])), //am pus sa se bage ~sign pe c[6] in loc de c[8] si ramane c[6] doar pt cnt++ (sper ca nu se strica altceva lol)
	.a(((({8{c[1]}} & inbus[7:0])  | ({8{c[7]}} & Q))) | ({8{c[2]}} & inbus[7:0])),
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
	.sel( ({2{c[11]}}) | ({2{c[12]}}) ),
	.bsRight(1'b0),
	.bsLeft(1'b0),
	.a({{8{1'b0}}, {8{c[11]}} & A} | {{{8{c[12]}} & A}, {8{c[12]}} & Q}),
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
    for(i = 0; i < 78; i = i + 1) begin
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
end

initial begin
    $display("Time\tclk\trst\tstart\tsel\tinbus\tsign\tA\tM\tQ\tq_min1\tc0\tc1\tc2\tc3\tc4\tc5\tc6\tc8\tc9\tc10\tc11\tc12\tcnt7\toutbus\tfinish");
    $monitor("%0t\t%b\t%b\t%b\t%02b\t%0d\t%b\t%8b\t%0d\t%0d\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%0d\t%0d\t%b", 
        $time, clk, rst, start, sel, inbus, 
        a.sign, a.A, a.M, a.Q, a.q_min1,
        a.c[0], a.c[1], a.c[2], a.c[3], a.c[4], a.c[5], a.c[6], a.c[8], a.c[9], a.c[10], a.c[11], a.c[12],
        a.cnt7, outbus, finish);
end


endmodule
