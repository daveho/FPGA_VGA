// Host interface (allowing the host to read and write data)

module host_interface( input nrst,
                       input clk,
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
                       // host address
                       output [12:0] hostAddr, // the VRAM address the host wants to write or read
                       // write interface to the VRAM
                       output [7:0] hostWrData,  // data to write to VRAM (selected by hostAddr)
                       output hostWr,            // 1=write data, 0=don't write data
                       // read interface to the VRAM
                       input [7:0] hostRdData    // data read from VRAM (selected by hostAddr)
                       );

  // data transfer directions
  localparam DIR_HOST_TO_DISPLAY = 1'b1; // the default, and when host is writing data to VRAM or bank reg
  localparam DIR_DISPLAY_TO_HOST = 1'b0; // only when the host is explicitly trying to read VRAM

  // register to determine whether data is output to the host data bus
  // (0=output data to host data bus, 1=port is high impedence)
  reg nOutputToHost;

/*
  // if we're outputting data to the host data bus, it's the data
  // read from the VRAM, otherwise the port is set to high impedence
  assign hostBusData = (nOutputToHost == DIR_DISPLAY_TO_HOST) ? hostRdData : 8'bZZZZZZZZ;
*/
  assign hostBusData = 8'bZZZZZZZZ;

  // control the data direction of the 74VLC245 transceiver interfacing
  // the FPGA to the host data bus
  assign hostBusDir = nOutputToHost;

/*
  // registers to control outputs to hostSelect and hostRd signals
  reg hostSelectReg, hostRdReg;
  assign hostSelect = hostSelectReg;
  assign hostRd = hostRdReg;
*/
  reg hostWrReg;
  assign hostWr = hostWrReg;

  // Bank register. Unlike the HW_VGA implementation, this only selects
  // the VRAM bank, and does not select a font. (Future: if we move the
  // font data to the SPRAM, multiple fonts would be possible.)
  reg [7:0] bankReg;

  // data read from or written to VRAM is addressed by
  // the bank register (high 2 bits) and the hostBusAddr
  // (low 11 bits)
  assign hostAddr = { bankReg[1:0], hostBusAddr };

  // when data is written to the VRAM, it comes from hostBusData
  assign hostWrData = hostBusData;

  always @( posedge clk ) begin

    if ( nrst == 1'b0 ) begin
      // in reset
      nOutputToHost = DIR_DISPLAY_TO_HOST; // don't output to host bus
      bankReg <= 8'd0;
/*
      hostSelectReg <= 1'b0;
      hostRdReg <= 1'b1;
*/
      hostWrReg <= 1'b0;
    end else begin
      // not in reset

      if ( nHostRMEM == 1'b0 & nHostVRAMEn == 1'b0 ) begin
        // host wants to read data from VRAM;
        // address should be valid, so all we
        // should need to do is set the bus direction
        // and tell the VRAM that we want to read; data
        // will appear on the host data bus on the next
        // clock cycle
/*
        nOutputToHost <= DIR_DISPLAY_TO_HOST;
        hostSelectReg <= 1'b1;
        hostRdReg <= 1'b1; // 1=read data from VRAM
*/
        // FIXME: this can't be supported yet
      end else if ( nHostWMEM == 1'b0 & nHostBankRegEn == 1'b0 ) begin
        // host wants to write data to the bank register
        nOutputToHost <= DIR_HOST_TO_DISPLAY;
        bankReg <= hostBusData;
      end else if ( nHostWMEM == 1'b0 & nHostVRAMEn == 1'b0 ) begin
        // host wants to write data to VRAM;
        // address and host data should be valid, so all
        // we should need to do is set the bus direction
        // and tell the VRAM we want to write
        nOutputToHost <= DIR_HOST_TO_DISPLAY;
        hostWrReg <= 1'b1;
      end else begin
        // host is neither reading nor writing:
        // make sure bus direction is DIR_HOST_TO_DISPLAY
        // and that the VRAM is not selected
        nOutputToHost <= DIR_HOST_TO_DISPLAY;
/*
        hostSelectReg <= 1'b0;
        hostRdReg <= 1'b1;
*/
        hostWrReg <= 1'b0;
      end

    end

  end

endmodule
