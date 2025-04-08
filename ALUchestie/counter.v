module tff(
input clk, rst, t,
output reg q
);

always @(posedge clk, posedge rst) begin
	if(rst)
		q<=0;
	else begin
	if(t==0)
		q <= q;
	else
		q <= ~q;
	end
end

endmodule

module counter(
	input c8, c9, clk, rst,
	output reg cnt7
);

wire q0, q1, q2;

tff inst2(.clk(clk), .rst(rst), .t((c8 | c9) & q0 & q1), .q(q2));
tff inst1(.clk(clk), .rst(rst), .t((c8 | c9) & q0), .q(q1));
tff inst0(.clk(clk), .rst(rst), .t(c8 | c9), .q(q0));

assign cnt7 = q0 & q1 & q2;
endmodule

module counter_tb;
	reg clk, rst, c8, c9;
	wire cnt7;

	counter inst(
	.clk(clk),
	.rst(rst),
	.c8(c8),
	.c9(c9),
	.cnt7(cnt7)
);

	localparam CLK_PERIOD = 100, RUNNING_CYCLES=28, RST_DURATION = 25;

	initial begin
		clk = 0;
		repeat(2*RUNNING_CYCLES) #(CLK_PERIOD/2) clk=~clk;
	end

	initial begin 
		rst=1;
		#RST_DURATION rst=0;
	end

	initial begin
		repeat(14) #(CLK_PERIOD/2) {c8,c9} = 2'b00;
		repeat(14) #(CLK_PERIOD/2) {c8,c9} = 2'b01;
		repeat(14) #(CLK_PERIOD/2) {c8,c9} = 2'b10;
	end

	  initial begin
    $display("TIME\tc8\tc9\tcnt7");
    $monitor("%0t\t%b\t%b\t%b",$time,c8, c9, cnt7);
  end

endmodule