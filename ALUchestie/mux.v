module mux(
	input[3:0] d,
	input[1:0] sel,
	output out
);

wire p0, p1, p2, p3;

assign p0 = d[0] & ~(sel[1]) & ~(sel[0]);
assign p1 = d[1] & ~(sel[1]) & sel[0];
assign p2 = d[2] & sel[1] & ~(sel[0]);
assign p3 = d[3] & sel[1] & sel[0];

assign out = p0 | p1 | p2 | p3;

endmodule

module mux_tb;

    reg [3:0] d;
    reg [1:0] sel;
    wire out;

    mux uut (
        .d(d),
        .sel(sel),
        .out(out)
    );

    initial begin
        $display("Time\t sel\t d\t out");
        $monitor("%0t\t %b\t %b\t %b", $time, sel, d, out);

       
        d = 4'b1010; 

        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;

       
        d = 4'b1100;
        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;
    end

endmodule
