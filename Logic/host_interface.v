// Host interface (allowing the host to read and write data)

module host_interface( input clk,
                       // host data/addr busses and control signals
                       input [10:0] hostBusAddr,
                       inout [7:0] hostBusData,
                       input nHostRMEM,
                       input nHostWMEM,
                       // VRAM and bank register enables (from address decode GAL)
                       input nHostVRAMEn,
                       input nHostBankRegEn,
                       // direction control for 74VLC245 transceiver interfacing
                       // host data bus (1=host writes, 0=host reads)
                       output hostBusDir,
                       // interface to display side of VRAM
                       input [7:0] hostRdData,
                       output hostSelect,
                       output hostRd,
                       output [12:0] hostAddr,
                       output [7:0] hostWrData );

  // for now, don't do anything with the host side of the VRAM
  assign hostAddr = 13'd0;
  assign hostSelect = 1'b0;
  assign hostRd = 1'b1;

  // Host bus data direction control.

  // host wants to read from display controller (nHostRMEM asserted)
  localparam BUS_HOST_READ = 1'b0;

  // host wants to write to display controller (nHostWMEM asserted)
  localparam BUS_HOST_WRITE = 1'b1;

  // for now, host interface is disable (hostBusData set to hi-Z,
  // hostBusDir set to BUS_HOST_WRITE)
  assign hostBusData = "xxxxxxxx";
  assign hostBusDir = BUS_HOST_WRITE;

endmodule
