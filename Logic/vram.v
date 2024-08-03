// VRAM module

// The host interface will be able to read and write, and the display
// controller will just read.

// This is intended to be inferred as 16 512B dual port block RAMs.

module vram( // Inputs
             input clk,

             // Host-side inputs
             input [12:0] hostAddr,      // host-side address
             input [7:0] hostWrData,     // data to write
             input hostSelect,           // 1=selected, 0=not selected
             input hostRd,               // 1=read, 0=write

             // Display controller-side inputs
             input [12:0] displayAddr,   // display-side address

             // Outputs
             output [7:0] hostRdData,    // data read from host side
             output [7:0] displayRdData  // data read from display side
             );

  // video memory
  reg [7:0] vramData[12:0];

  // initialize first 4800 bytes of VRAM with a picture of Ingo
  initial begin
    //`include "init_vram.vh"
    vramData[13'd0] = 8'd31;
  end

  // registers for data read from video memory
  reg [7:0] hostRdDataReg;
  reg [7:0] displayRdDataReg;

  always @( posedge clk ) begin

    if ( hostSelect ) begin
      // VRAM selected from host side

      if ( hostRd ) begin
        // read data from host side
        hostRdDataReg <= vramData[hostAddr];
      end else begin
        // write data from host  side
        vramData[hostAddr] <= hostWrData;
      end
    end

    // on the display side, we just output whatever data
    // is selected by displayAddr
    displayRdDataReg <= vramData[displayAddr];

  end

  // drive outputs from read data registers
  assign hostRdData = hostRdDataReg;
  assign displayRdData = displayRdDataReg;

endmodule
