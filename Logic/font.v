// font module (goal is to have it inferred as block RAM)

module font( input clk,
             input [11:0] fontRdAddr,
             output [7:0] fontRdData);

  // Font data (ideally, will be inferred as 8 512B block RAMS,
  // although the SPRAM would also work)
  reg [7:0] fontData[4095:0];
  initial begin
    `include "init_font.vh"
  end

  // register to store current data read from font ROM
  reg [7:0] fontRdDataReg;

  always @( posedge clk ) begin
    fontRdDataReg <= fontData[fontRdAddr];
  end

  // contents of font read data register are driven as the
  // module's fontRdData output
  assign fontRdData = fontRdDataReg;

endmodule
