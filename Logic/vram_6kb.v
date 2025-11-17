// VRAM module allowing for 6 KB of memory with
// independent read and write ports, mapped into an
// 8 KB address space. The upper 2 KB of VRAM is
// mirrored twice in the upper 4 KB of the 8 KB address
// space.

// The motivation for this module is work around the
// limitation that the ICE40 block RAMS only have
// a single read port and a single write port.
// To allow the host system to both read and write,
// and to allow the rasterization hardware to read,
// we need 1 x write and 2 x read ports. We can fake this
// by implementing mirrored VRAM instances with identical
// contents. All host writes go to both, and each
// instance has its own read port to be used by the
// host system and the rasterization hardware. The
// UP5K used in the Upduino 3 only has 15 KB of block
// RAM, so not enough for 2 x 8KB. However, 2 x 6KB should
// work.

module vram_6k( // Inputs
                input clk,
   
                // Write interface
                input [12:0] vramWrAddr,    // host-side write address
                input [7:0] vramWrData,     // data to write
                input vramWr,               // 1=write to VRAM, 0=don't write
   
                // Read interface
                input [12:0] vramRdAddr,    // display-side address
                output [7:0] vramRdData     // data read from display side
                );

  // VRAM lower (4KB) and upper (2KB) banks.
  // We want yosys to infer these as block RAM.
  reg [7:0] vramDataLower[4095:0];
  reg [7:0] vramDataUpper[2047:0];

  // register for byte read from video memory
  reg [7:0] vramRdDataReg;

  always @( posedge clk ) begin

    // Write to lower bank?
    if ( vramWr == 1'b1 & vramWrAddr[11] == 0'b0 ) begin
      vramDataLower[vramWrAddr[11:0]] <= vramWrData;
    end

    // Write to upper bank?
    if ( vramWr == 1'b1 & vramWrAddr[11] == 0'b1 ) begin
      vramDataUpper[vramWrAddr[10:0]] <= vramWrData;
    end

    // Copy read data to vramRdDataReg, selecting from lower or upper
    // bank using high bit of vramRdAddr
    if ( vramRdAddr[11] == 1'b0 ) begin
      vramRdDataReg <= vramDataLower[vramRdAddr[11:0]]
    end else begin
      vramRdDataReg <= vramDataUpper[vramRdAddr[10:0]]
    end

  end

  // drive outputs from read data register
  assign vramRdData = vramRdDataReg;

endmodule
