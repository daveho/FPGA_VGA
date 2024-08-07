// VRAM module

// This is intended to be inferred as 16 512B dual port block RAMs.

// ICE40 block RAMS aren't true dual port memory. Rather, there
// are independent read and write ports. So, the memory fetch
// logic will need to handle both character and attribute
// data fetches (for pixel generation) and also reads by
// the host interface using the single read port.

module vram( // Inputs
             input clk,

             // Write interface
             input [12:0] vramWrAddr,    // host-side write address
             input [7:0] vramWrData,     // data to write
             input vramWr,               // 1=write to VRAM, 0=don't write

             // Display-side read interface
             input [12:0] readoutAddr,   // display-side address
             output [7:0] readoutData    // data read from display side
             );

  // video memory
  reg [7:0] vramData[8192:0];

  // initialize first 4800 bytes of VRAM with a picture of Ingo
  initial begin
    `include "init_vram.vh"
  end

  // registers for data read from video memory
  reg [7:0] readoutDataReg;

  always @( posedge clk ) begin

    if ( vramWr ) begin
      // write data from host  side
      vramData[vramWrAddr] <= vramWrData;
    end

    // on the display side, we just output whatever data
    // is selected by displayAddr
    readoutDataReg <= vramData[readoutAddr];

  end

  // drive outputs from read data registers
  assign readoutData = readoutDataReg;

endmodule
