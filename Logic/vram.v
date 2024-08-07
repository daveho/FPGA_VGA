// VRAM module

// This is intended to be inferred as 16 512B dual port block RAMs.

// ICE40 block RAMS aren't true dual port memory. Rather, there
// are independent read and write ports. So, the memory fetch
// logic needs to handle both readout (character and attribute)
// data fetches for pixel generation and also reads by
// the host interface using the single read port. This is implemented
// by fetching readout and host data on alternating clock cycles.
// This means that data will appear in either 1 or 2 cycles
// when an address is presented, which is no big deal, since neither
// the pixel generator nor the host interface expect the read data
// to appear immediately.

module vram( // Inputs
             input nrst,
             input clk,

             // Host address (used for both writes and reads)
             input [12:0] hostAddr,    // host-side write address

             // Write interface
             input [7:0] vramWrData,     // data to write
             input vramWr,               // 1=write to VRAM, 0=don't write

             // Display-side read interface
             input [12:0] readoutAddr,   // display-side address
             output [7:0] readoutData,   // data read from display side

             // Host-side read interface
             output [7:0] hostData       // data read from host side
             );

  // video memory
  reg [7:0] vramData[8192:0];

  // initialize first 4800 bytes of VRAM with a picture of Ingo
  initial begin
    `include "init_vram.vh"
  end

  // register to keep track of whether data is read from
  // the readout address or the host address (these are done
  // on alternating cycles in order to multiplex the single
  // hardware block RAM read port)
  reg toggle;

  // register for data read from video memory
  reg [7:0] readoutDataReg;     // readout data (to be used by the pixel generator)
  reg [7:0] hostDataReg;        // host data (to be used by the host interface)

  always @( posedge clk ) begin

    if ( nrst == 1'b0 ) begin
      // in reset
      toggle <= 1'b0;
      readoutDataReg <= 8'd0;
      hostDataReg <= 8'd0;
    end else begin
      // not in reset

      if ( vramWr ) begin
        // write data from host  side
        vramData[hostAddr] <= vramWrData;
      end

      if ( toggle == 1'b0 ) begin
        // on the display side, we just output whatever data
        // is selected by readoutAddr
        readoutDataReg <= vramData[readoutAddr];
      end else begin
        // read data selected by host address
        hostDataReg <= vramData[hostAddr];
      end

      // update toggle
      toggle <= ~toggle;

    end

  end

  // drive outputs from read data registers
  assign readoutData = readoutDataReg;
  assign hostData = hostDataReg;

endmodule
