`include"mux.v"
`include"dff.v"
module ushift(
	input[7:0]a,
	input[1:0] sel,
	input bsRight, bsLeft, reset, clk,
	output wire[7:0]a_shifted
);

wire out_mux[7:0];

mux mux0(.sel(sel), .d({a[0], bsLeft, a_shifted[1], a_shifted[0]}), .out(out_mux[0]));
mux mux1(.sel(sel), .d({a[1], a_shifted[0], a_shifted[2], a_shifted[1]}), .out(out_mux[1]));
mux mux2(.sel(sel), .d({a[2], a_shifted[1], a_shifted[3], a_shifted[2]}), .out(out_mux[2]));
mux mux3(.sel(sel), .d({a[3], a_shifted[2], a_shifted[4], a_shifted[3]}), .out(out_mux[3]));
mux mux4(.sel(sel), .d({a[4], a_shifted[3], a_shifted[5], a_shifted[4]}), .out(out_mux[4]));
mux mux5(.sel(sel), .d({a[5], a_shifted[4], a_shifted[6], a_shifted[5]}), .out(out_mux[5]));
mux mux6(.sel(sel), .d({a[6], a_shifted[5], a_shifted[7], a_shifted[6]}), .out(out_mux[6]));
mux mux7(.sel(sel), .d({a[7],a_shifted[6], bsRight, a_shifted[7]}), .out(out_mux[7]));

dff dff0(.clk(clk), .reset(reset), .d(out_mux[0]), .q(a_shifted[0]));
dff dff1(.clk(clk), .reset(reset), .d(out_mux[1]), .q(a_shifted[1]));
dff dff2(.clk(clk), .reset(reset), .d(out_mux[2]), .q(a_shifted[2]));
dff dff3(.clk(clk), .reset(reset), .d(out_mux[3]), .q(a_shifted[3]));
dff dff4(.clk(clk), .reset(reset), .d(out_mux[4]), .q(a_shifted[4]));
dff dff5(.clk(clk), .reset(reset), .d(out_mux[5]), .q(a_shifted[5]));
dff dff6(.clk(clk), .reset(reset), .d(out_mux[6]), .q(a_shifted[6]));
dff dff7(.clk(clk), .reset(reset), .d(out_mux[7]), .q(a_shifted[7]));

endmodule

module ushift_tb;

  reg [7:0] a;
  reg [1:0] sel;
  reg bsRight, bsLeft, reset, clk;
  wire [7:0] a_shifted;

  // Instan?ierea modulului de testat
  ushift uut (
    .a(a),
    .sel(sel),
    .bsRight(bsRight),
    .bsLeft(bsLeft),
    .reset(reset),
    .clk(clk),
    .a_shifted(a_shifted)
  );

  // Clock generator
  always #5 clk = ~clk;

  initial begin
    $dumpfile("ushift_tb.vcd");
    $dumpvars(0, ushift_tb);

    clk = 0;
    reset = 1;
    a = 8'b10110011;
    sel = 2'b11;  // Load value
    bsRight = 1'b1;
    bsLeft = 1'b0;

    #10 reset = 0;  // Scoatem din reset
    #10;

    // Test?m men?inerea valorii (00)
    sel = 2'b00;
    #10;

    // Shift stânga (01)
    sel = 2'b01;
    bsLeft = 1'b1;
    #10;

    // Shift dreapta (10)
    sel = 2'b10;
    bsRight = 1'b0;
    #10;

    // Reînc?rcare
    sel = 2'b11;
    a = 8'b11110000;
    #10;

    // Înc? un shift la stânga
    sel = 2'b01;
    bsLeft = 1'b1;
    #10;

    $display("Test completed.");
  end

  initial begin
    $monitor("Time=%0t | sel=%b | bsL=%b | bsR=%b | a=%b | a_shifted=%b",
             $time, sel, bsLeft, bsRight, a, a_shifted);
  end

endmodule
