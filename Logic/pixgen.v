// Pixel generator module (based on HW_VGA pixel generator and PxGenCtrl.pld)

// Note that unlike HW_VGA, the pixel generator does *not*
// duplicate the readout module's state machine.
// Instead, it takes its readoutCount and active signal as inputs.

module pixgen( // Inputs
               input nrst,
               input clk,
               input [7:0] readoutData,
               input nVis,
               input [2:0] readoutCount, // from readout module
               input active,             // from readout module
               // Outputs
               output bgRed,
               output bgGreen,
               output bgBlue,
               output bgIntense,
               output fgRed,
               output fgGreen,
               output fgBlue,
               output fgIntense,
               output pixel
             );

  // Font data (ideally, will be inferred as 8 512B block RAMS,
  // although the SPRAM would also work)
  reg [7:0] fontData[4095:0];
  initial begin
    `include "init_font.vh"
  end

  // character and attribute registers
  reg [7:0] charReg;
  reg [7:0] attrReg;

  // output shift register
  reg [7:0] shiftReg;

  always @( posedge clk ) begin
    if ( nrst == 1'b0 ) begin
      // in reset
      attrReg <= 8'd0;
      charReg <= 8'd0;
      shiftReg <= 8'd0;
    end else begin
      // not in reset
    end
  end

  // drive outputs
  assign bgRed = attrReg[0];
  assign bgGreen = attrReg[1];
  assign bgBlue = attrReg[2];
  assign bgIntense = attrReg[3];
  assign fgRed = attrReg[4];
  assign fgGreen = attrReg[5];
  assign fgBlue = attrReg[6];
  assign fgIntense = attrReg[7];
  assign pixel = shiftReg[7];

endmodule
