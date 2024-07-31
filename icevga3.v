// Third attempt at implementing a VGA text mode display
// using an ICE40 FPGA

module icevga3(input nrst,
               input ext_osc,
               output red,
               output green,
               output blue,
               output intense,
               output hsync,
               output vsync);

  // Use the global clock buffer to distribute the 25.175 MHz VGA dot clock
  wire clk;
  SB_GB clk_buffer(.USER_SIGNAL_TO_GLOBAL_BUFFER(ext_osc),
                   .GLOBAL_BUFFER_OUTPUT(clk));

  // For now, just output clk/2 on hsync,
  // clk/4 on vsync, and other outputs are set to 1.
  reg [1:0] count;
  always @(posedge clk) begin
    if ( nrst == 1'b0 ) begin
      // in reset
      count <= 2'b00;
    end else begin
      // not in reset
      count <= count + 2'b01;
    end
  end

  assign hsync = count[0];
  assign vsync = count[1];

  assign red = 1'b1;
  assign green = 1'b1;
  assign blue = 1'b1;
  assign intense = 1'b1;

endmodule
