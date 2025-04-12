`include"mux.v"
`include"dff.v"
module ushift #(
    parameter WIDTH = 8
)(
    input [WIDTH-1:0] a,
    input [1:0] sel,
    input bsRight, bsLeft, reset, clk,
    output wire [WIDTH-1:0] a_shifted
);

    wire [WIDTH-1:0] out_mux;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : shift_logic
            wire d0, d1, d2, d3;

            assign d0 = a[i];
            assign d1 = (i == 0) ? bsLeft : a_shifted[i - 1];
            assign d2 = (i == WIDTH - 1) ? bsRight : a_shifted[i + 1];
            assign d3 = a_shifted[i];

            mux m (
                .sel(sel),
                .d({d0, d1, d2, d3}),
                .out(out_mux[i])
            );

            dff ff (
                .clk(clk),
                .reset(reset),
                .d(out_mux[i]),
                .q(a_shifted[i])
            );
        end
    endgenerate

endmodule


   
module ushift_tb;

  parameter WIDTH = 8;

  reg [WIDTH-1:0] a;
  reg [1:0] sel;
  reg bsRight, bsLeft, reset, clk;
  wire [WIDTH-1:0] a_shifted;

  ushift #(.WIDTH(WIDTH)) uut (
    .a(a),
    .sel(sel),
    .bsRight(bsRight),
    .bsLeft(bsLeft),
    .reset(reset),
    .clk(clk),
    .a_shifted(a_shifted)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("ushift_tb.vcd");
    $dumpvars(0, ushift_tb);

    clk = 0;
    reset = 1;
    a = 8'b10110011;
    sel = 2'b11;  // Load
    bsRight = 1'b1;
    bsLeft = 1'b0;

    #10 reset = 0;
    #10;

    sel = 2'b00;  // No change
    #10;

    sel = 2'b01;  // Shift left
    bsLeft = 1'b1;
    #10;

    sel = 2'b10;  // Shift right
    bsRight = 1'b0;
    #10;

    sel = 2'b11;  // Reload
    a = 8'b11110000;
    #10;

    sel = 2'b01;  // Shift left again
    bsLeft = 1'b1;
    #10;

    $display("Test completed.");
   
  end

  initial begin
    $monitor("Time=%0t | sel=%b | bsL=%b | bsR=%b | a=%b | a_shifted=%b",
             $time, sel, bsLeft, bsRight, a, a_shifted);
  end

endmodule
