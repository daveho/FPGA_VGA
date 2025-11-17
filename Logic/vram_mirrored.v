// "Mirrored" VRAM implementation

module vram( // Inputs
             input clk,

             // Write interface
             input [12:0] vramWrAddr,    // host-side write address
             input [7:0] vramWrData,     // data to write
             input vramWr,               // 1=write to VRAM, 0=don't write

             // Read interface
             input [12:0] vramRdAddr,    // display-side address
             output [7:0] vramRdData,    // data read from display side

             // Second read interface
             input [12:0] vramRdAddr2,   // host-side read address
             output [7:0] vramRdData2    // data read from host side
             );

  // TODO

endmodule
