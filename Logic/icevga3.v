// Third attempt at implementing a VGA text mode display
// using an ICE40 FPGA

`default_nettype none

module icevga3( // clock and reset
                input nrst,
                input ext_osc,
                // host interface
                input [10:0] hostBusAddr,
                inout [7:0] hostBusData,
                input nHostRMEM,
                input nHostWMEM,
                input nHostVRAMEn,
                input nHostBankRegEn,
                output hostBusDir,
                // outputs to monitor
                output redOut,
                output greenOut,
                output blueOut,
                output intenseOut,
                output hSyncOut,
                output vSyncOut );

  // Use the global clock buffer to distribute the 25.175 MHz VGA dot clock
  wire clk;
  SB_GB clk_buffer( .USER_SIGNAL_TO_GLOBAL_BUFFER( ext_osc ),
                    .GLOBAL_BUFFER_OUTPUT( clk ) );

  // hcount module and signals

  wire hCountEnd, hBeginPulse, hEndPulse, hVisEnd, hBeginActive, hEndActive;

  hcount hcount_instance( .nrst( nrst ),
                          .clk( clk ),
                          .hCountEnd( hCountEnd ),
                          .hBeginPulse( hBeginPulse ),
                          .hEndPulse( hEndPulse ),
                          .hVisEnd( hVisEnd ),
                          .hBeginActive( hBeginActive ),
                          .hEndActive( hEndActive ) );

  // vcount module and signals

  wire vCountZero, vBeginPulse, vEndPulse, vVisEnd, vCountEnd, vEndActive;
  wire [11:0] vCount;

  vcount vcount_instance( .nrst( nrst ),
                          .clk( clk ),
                          .vCountIncr( hEndPulse ), // v. count incremented at end of hsync pulse
                          .hCountEnd( hCountEnd ),
                          .vCountZero( vCountZero ),
                          .vBeginPulse( vBeginPulse ),
                          .vEndPulse( vEndPulse ),
                          .vVisEnd( vVisEnd ),
                          .vCountEnd( vCountEnd ),
                          .vEndActive( vEndActive ),
                          .vCount( vCount ) );

  // sync module and signals

  wire hSync, vSync, hVis, vVis, nVis, vActive;

  sync sync_instance( .nrst( nrst) ,
                      .clk( clk ),
                      .hBeginPulse( hBeginPulse ),
                      .hEndPulse( hEndPulse ),
                      .vBeginPulse( vBeginPulse ),
                      .vEndPulse( vEndPulse ),
                      .hCountEnd( hCountEnd ),
                      .vCountZero( vCountZero ),
                      .hVisEnd( hVisEnd ),
                      .vVisEnd( vVisEnd ),
                      .vCountEnd( vCountEnd ),
                      .vEndActive( vEndActive ),
                      .hSync( hSync ),
                      .vSync( vSync ),
                      .hVis( hVis ),
                      .vVis( vVis ),
                      .nVis( nVis ),
                      .vActive( vActive ) );

  // vga_output module and signals

  wire bgRed, bgGreen, bgBlue, bgIntense, fgRed, fgGreen, fgBlue, fgIntense, pixel;

  vga_output vga_output_instance( .clk( clk ),
                                  .bgRed( bgRed ),
                                  .bgGreen( bgGreen ),
                                  .bgBlue( bgBlue ),
                                  .bgIntense( bgIntense ),
                                  .fgRed( fgRed ),
                                  .fgGreen( fgGreen ),
                                  .fgBlue( fgBlue ),
                                  .fgIntense( fgIntense ),
                                  .pixel( pixel ),
                                  .hSync( hSync ),
                                  .vSync( vSync ),
                                  .nVis( nVis ),
                                  // the vga_output module's outputs drive the output pins
                                  // which drive the color and sync signals that ultimately
                                  // go to the VGA monitor
                                  .redOut( redOut ),
                                  .greenOut( greenOut ),
                                  .blueOut( blueOut ),
                                  .intenseOut( intenseOut ),
                                  .hSyncOut( hSyncOut ),
                                  .vSyncOut( vSyncOut ) );

/*
  // readout module and signals

  wire [12:0] readoutAddr;
  wire [2:0] readoutCount;
  wire active;

  readout readout_instance( // Inputs
                            .nrst( nrst ),
                            .clk( clk ),
                            .vActive( vActive ),
                            .hBeginActive( hBeginActive ),
                            .hEndActive( hEndActive ),
                            .vCount( vCount[3:0] ), // only need low 4 bits of vCount
                            .vSync( vSync ),
                            .hBeginPulse( hBeginPulse ),
                            // Output
                            .readoutAddr( readoutAddr ),
                            .readoutCount( readoutCount ),
                            .active( active ) );

  // vram module and signals

  wire [12:0] hostWrAddr;
  wire [7:0] vramWrData;
  wire hostWr;
  wire [7:0] vramRdData;

  vram vram_instance( // Inputs
                      .clk( clk ),
                      .vramWrAddr( hostWrAddr ),
                      .vramWrData( vramWrData ),
                      .vramWr( hostWr ),
                      .vramRdAddr( readoutAddr ), // displayAddr=readoutAddr
                      // Outputs
                      .vramRdData( vramRdData ) );

  // pixel generator module

  pixgen pixgen_instance(  // Inputs
                          .nrst( nrst ),
                          .clk( clk ),
                          .vramRdData( vramRdData ), // read data from display side of VRAM
                          .vCount( vCount[3:0] ),
                          .nVis( nVis ),
                          .readoutCount( readoutCount ),
                          .active( active ),
                          // Outputs
                          .bgRed( bgRed ),
                          .bgGreen( bgGreen ),
                          .bgBlue( bgBlue ),
                          .bgIntense( bgIntense ),
                          .fgRed( fgRed ),
                          .fgGreen( fgGreen ),
                          .fgBlue( fgBlue ),
                          .fgIntense( fgIntense ),
                          .pixel( pixel ) );

  // host_interface module

  host_interface host_interface_instance( .nrst( nrst ),
                                          .clk( clk ),
                                          .hostBusAddr( hostBusAddr ),
                                          .hostBusData( hostBusData ),
                                          .nHostRMEM( nHostRMEM ),
                                          .nHostWMEM( nHostWMEM ),
                                          .nHostVRAMEn( nHostVRAMEn ),
                                          .nHostBankRegEn( nHostBankRegEn ),
                                          .hostBusDir( hostBusDir ),
                                          .hostWrAddr( hostWrAddr ),
                                          .hostWrData( vramWrData ),
                                          .hostWr( hostWr ) );
*/

/*
  assign hostSelect = 1'b0;
  assign hostRd = 1'b1;
  assign hostAddr = 13'd0;
  assign hostBusData = 8'bZZZZZZZZ;
  assign hostBusDir = 1'b1;
*/

endmodule
