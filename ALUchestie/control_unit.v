module control_unit(
	input clk, rst, start,
	input [1:0] sel,
	input q_0, q_min1, sign, cnt7,
	output reg[12:0] c,
	output reg finish 
);

localparam ST_0 = 4'd0;
localparam ST_1 = 4'd1;
localparam ST_2 = 4'd2;
localparam ST_3 = 4'd3;
localparam ST_4 = 4'd4;
localparam ST_5 = 4'd5;
localparam ST_6 = 4'd6;
localparam ST_7 = 4'd7;
localparam ST_8 = 4'd8;
localparam ST_9 = 4'd9;
localparam ST_10 = 4'd10;
localparam ST_11 = 4'd11;
localparam ST_12 = 4'd12;
localparam ST_13 = 4'd13;

reg[13:0] st;
wire[13:0] st_next;


//ecuatii de feedback
assign st_next[ST_0] = (st[ST_0] & ~start) | (st[ST_13]) | (st[ST_12] & ~(sel[1]));
assign st_next[ST_1] = (~(sel[1]) & start & st[ST_0]);
assign st_next[ST_2] = sel[1] & ~(sel[0]) & start & st[ST_0];
assign st_next[ST_3] = sel[1] & sel[0] & start & st[ST_0];
assign st_next[ST_4] = st[ST_1] | st[ST_2] | st[ST_3];
assign st_next[ST_5] = st[ST_4] & (
                         (~sel[1] & ~sel[0]) | 
                         (sel[1] & sel[0] & sign) | 
                         (sel[1] & ~sel[0] & ~q_0 & q_min1)
                       ) | 
                       (st[ST_10] & sel[1] & ~sel[0] & ~q_0 & q_min1 & ~cnt7) | //adaugat nou Alexia 
		       (st[ST_9] & ~(cnt7) & sel[1] & sel[0] & sign); //adaugat nou -Alex 
assign st_next[ST_6] = st[ST_4] & (
                         (~sel[1] & sel[0]) | 
                         (sel[1] & sel[0] & ~sign) | 
                         (sel[1] & ~sel[0] & ~q_0 & q_min1)
                       ) | 
                       (st[ST_10] & sel[1] & ~sel[0] & q_0 & ~q_min1 & ~cnt7) |  //adaugat nou Alexia 
			(st[ST_9] & ~(cnt7) & sel[1] & sel[0] & ~(sign)); //adaugat nou -Alex

assign st_next[ST_7] = ((st[ST_5] | st[ST_6]) & sel[1] & sel[0]) | (st[ST_9] & ~(cnt7) & sel[1] & sel[0] & (st[ST_5] | st[ST_6])); //adaugat nou -Alex 

assign st_next[ST_8] = (st[ST_5] | st[ST_6]) & (sel[1] & ~(sel[0])) |
	(q_0 ~^ q_min1) & (st[ST_4] & sel[1] & ~(sel[0])) | 
	(q_0 ~^ q_min1) & (st[ST_10] & sel[1] & ~(sel[0]) & ~(cnt7)); //rand nou Alexia 

assign st_next[ST_9] = st[ST_7];

assign st_next[ST_10] = st[ST_8];

assign st_next[ST_11] = sign & cnt7 & st[ST_9];

assign st_next[ST_12] = (st[ST_5] | st[ST_6]) & ~(sel[1]) | 
	st[ST_11] | (st[ST_9] & cnt7 & ~(sign)) | (st[ST_10] & cnt7);

assign st_next[ST_13] = sel[1] & st[ST_12];


//ecuatiile de iesire 
assign c[0] = st[ST_1];
assign c[1] = st[ST_2];
assign c[2] = st[ST_3];
assign c[3] = st[ST_4];
assign c[4] = st[ST_5] | st[ST_6];
assign c[5] = st[ST_6];
assign c[6] = st[ST_7];
assign c[7] = st[ST_8];
assign c[8] = st[ST_9];
assign c[9] = st[ST_10];
assign c[10] = st[ST_11];
assign c[11] = st[ST_12];
assign c[12] = st[ST_13];
assign finish = st[ST_0];
 
always @(posedge clk or posedge rst)
begin 
	if(rst) 
	begin
	st <= ST_0;
	st[ST_0] <= 1;
	end
	else st <= st_next;
end 
endmodule


module control_unit_tb;
reg clk, rst, start;
reg [1:0] sel;
reg q_0, q_min1, sign, cnt7;
wire[12:0] c;
wire finish;


control_unit cutb(
.clk(clk),
.rst(rst),
.sign(sign),
.start(start),
.q_0(q_0),
.q_min1(q_min1),
.sel(sel),
.cnt7(cnt7),
.c(c),
.finish(finish)
);


initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    clk=0;
    rst=1;
    sel=2; 
    start=0;
    q_0=0;
    q_min1=0;
    sign=0;
    cnt7=0;
    #1000;
    cnt7=1;
    #50;
  end
  initial begin
    #25; rst=~rst;
  end
  
  initial begin
    #40; start=1;
    #60; start=0;
  end
  
  integer j;
  initial begin
    for(j=1;j<=100;j=j+1)
    begin
      #20; clk=~clk;
    end
    #50;
  end
  
  initial begin
    $display("TIME\tsel\tstart\tq_0\tq_min1\tsign\tcnt7\tc\t\tcurrent_state\tnext_state\tfinish");
    $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%d\t\t%d\t\t%b",$time,sel,start,q_0,q_min1,sign,cnt7,c,$clog2(cutb.st),$clog2(cutb.st_next),finish);
  end
endmodule
