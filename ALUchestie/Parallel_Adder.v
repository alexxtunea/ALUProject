module fac(
	input x, y, cin,
	output z, cout
);

assign z=x^y^cin;
assign cout=(x&y) | (x&cin) | (y&cin);
endmodule

module Parallel_Adder(
	input [8:0] x, y,
	input cin,
	output [8:0] z,
	output cout
);

wire [8:0]cout_aux;
genvar i;
generate 
for(i=0; i<9; i=i+1)
begin 
	if(i==0) begin
	fac f0(
		.x(x[0]),
		.y(y[0]),
		.cin(cin),
		.z(z[0]),
		.cout(cout_aux[0])
	);
	end
	else if(i==8) begin
	fac f8(
		.x(x[8]),
		.y(y[8]),
		.cin(cout_aux[7]),
		.z(z[8]),
		.cout(cout)
	);
	end
	else begin
	fac fmid(
		.x(x[i]),
		.y(y[i]),
		.cin(cout_aux[i-1]),
		.z(z[i]),
		.cout(cout_aux[i])
	);
	end
	end
endgenerate
endmodule

module Parallel_Adder_tb;
reg [8:0] x, y;
reg cin;
wire [8:0] z;
wire cout;
Parallel_Adder P(
	.x(x),
	.y(y),
	.cin(cin),
	.z(z),
	.cout(cout)
);
integer k;
initial begin
	$display("Time\tx\t  y\t    cin\t\tcout\tz");
        $monitor("%0t\t%b\t%b\t%b\t\t%b\t%b", $time, x, y, cin, cout, z);
        for (k = 0; k < 30024; k = k + 9) begin
            {x, y, cin} = k;
            #10; 
        end
end
endmodule

