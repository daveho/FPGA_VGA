// Testbench for readout module.
// This also (indirectly) tests the sync module.

`include "testbench.vh"

module readout_tb();

  `include "timing.vh"

  // Tick counter (used by  `TICK macro)
  integer ticks;

  // Loop counter (used by `GENCLOCK macro)
  integer k;

  // The testbench just needs to control -RST and CLK
  reg nrst, clk;

  // Outputs generated by the hcount module
  wire hCountEnd, hBeginPulse, hEndPulse, hVisEnd, hBeginActive, hEndActive;

  // Outputs generated by the vcount module
  wire vCountZero, vBeginPulse, vEndPulse, vVisEnd, vCountEnd, vEndActive;
  wire [11:0] vCount;

  // Outputs generated by the sync module
  wire hSync, vSync, hVis, vVis, nVis, vActive;

  // Outputs generated by the Readout module
  wire [12:0] readoutAddr;

  // Instantiate hcount module
  hcount hcount_instance( // Inputs
                          .nrst( nrst ),
                          .clk( clk ),
                          // Outputs
                          .hCountEnd( hCountEnd ),
                          .hBeginPulse( hBeginPulse ),
                          .hEndPulse( hEndPulse ),
                          .hVisEnd( hVisEnd ),
                          .hBeginActive( hBeginActive ),
                          .hEndActive( hEndActive ) );

  // Instantiate vcount module. Note that the hEndPulse signal
  // is used to generate the vCountIncr input to the vcount
  // module.
  vcount vcount_instance( // Inputs
                          .nrst( nrst ),
                          .clk( clk ),
                          .vCountIncr( hEndPulse ),
                          .hCountEnd( hCountEnd ),
                          // Outputs
                         .vCountZero( vCountZero ),
                         .vBeginPulse( vBeginPulse ),
                         .vEndPulse( vEndPulse ),
                         .vVisEnd( vVisEnd ),
                         .vCountEnd( vCountEnd ),
                         .vEndActive( vEndActive ),
                         .vCount( vCount ) );

  // Instantiate sync module
  sync sync_instance( // Inputs
                      .nrst( nrst ),
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
                      // Outputs
                      .hSync( hSync ),
                      .vSync( vSync ),
                      .hVis( hVis ),
                      .vVis( vVis ),
                      .nVis( nVis ),
                      .vActive( vActive ) );

  // Instantiate readout module
  readout readout_instance( // Inputs
                            .nrst( nrst ),
                            .clk( clk ),
                            .vActive( vActive ),
                            .hBeginActive( hBeginActive ),
                            .hEndActive( hEndActive ),
                            .vCount( vCount[3:0] ),
                            .vSync( vSync ),
                            .hBeginPulse( hBeginPulse ),
                            // Outputs
                            .readoutAddr( readoutAddr ) );

  // loop counter for tests
  integer i;

  initial begin
    // set tick count to 0
    ticks = 0;

    // generate dump file we can inspect using gtkwave
    $dumpfile( "readout_tb.vcd" );
    $dumpvars;

    // generate a reset pulse
    `RESET( nrst, clk );

    // advance until vEndPulse is asserted. This should clear
    // the readout address.
    while ( ~vEndPulse ) begin
      `TICK( clk );
    end
    //$display( "v end pulse at vcount %d, ticks=%d", vCount, ticks );
    `ASSERT( readoutAddr == 13'd0 );

    // advance until vActive and hBeginActive are both asserted.
    // this marks the beginning of readouot activity (just before the
    // first visible scanline)
    while ( ~(vActive & hBeginActive) ) begin
      `TICK( clk );
    end
    `ASSERT( vActive );
    `ASSERT( hBeginActive );
    //$display( "begin activity, vCount=%d, ticks=%d", vCount, ticks );

    // vCount should be 0 at this point: vCount is incremented
    // at hEndPulse, to allow vCount to be correct when activity
    // starts for the scanline that is about to be displayed)
    `ASSERT( vCount == 12'd0 );

    // Readout address should still be 0 (this is the first character
    // being fetched from VRAM)
    `ASSERT( readoutAddr == 13'd0 );

    // Advancing 3 cycles should lead to the readout address being
    // incremented (the first attribute fetch), meaning we'll see the
    // incremented readout address on the 4th cycle
    `TICK( clk );
    `ASSERT( readoutAddr == 13'd0 );
    `TICK( clk );
    `ASSERT( readoutAddr == 13'd0 );
    `TICK( clk );
    `ASSERT( readoutAddr == 13'd0 );
    `TICK( clk );
    `ASSERT( readoutAddr == 13'd1 );

    // advance to the end of the frame (which is only a few cycles away)
    while ( ~(hCountEnd & vCountZero) ) begin
      `TICK( clk );
    end

    // advance to the end of the visible part of the first scanline;
    // readoutAddr should be 160
    `GENCLOCK( 640, clk );
    `ASSERT( readoutAddr == 13'd160 );

    // advance to the end of the horizontal sync pulse
    while ( ~hEndPulse ) begin
      `TICK( clk );
    end

    // readoutAddr should have been reset back to 0
    //$display( "end of first scanline, readoutAddr=%d, ticks=%d", readoutAddr, ticks );
    `ASSERT( readoutAddr == 13'd0 );

    // advance to the end of the scanline
    while ( ~hCountEnd ) begin
      `TICK( clk );
    end

    // advance through 14 more scanlines: these are all part of the first row of
    // characters, so for each, at the end of of the visible horizontal region,
    // readoutAddr should be 160, and at the end of the hsync pulse, readoutAddr
    // should have been set back to 0
    for ( i = 0; i < 14; i++ ) begin
      // advance to end of horizontal visibility
      while ( ~hVisEnd ) begin
        `TICK( clk );
      end

      // readoutAddr should be 160
      `ASSERT( readoutAddr == 13'd160 );

      // advance to end of hsync pulse
      while ( ~hEndPulse ) begin
        `TICK( clk );
      end

      // readoutAddr should have been reset back to 0
      `ASSERT( readoutAddr == 13'd0 );
    end

    // last row of pixels in the first character row: readoutAddr should be be
    // 160 at the end of the horizontal visible region, but it should REMAIN 160
    // at the end of the hsync pulse
    while ( ~hVisEnd ) begin
      `TICK( clk );
    end
    `ASSERT( readoutAddr == 13'd160 );
    while ( ~hEndPulse ) begin
      `TICK( clk );
    end
    `ASSERT( readoutAddr == 13'd160 );

    // advance to end of scanline
    while ( ~hCountEnd ) begin
      `TICK( clk );
    end

    // advance to end of horizontal visible region: this is the first row of pixels
    // in the second character row, so after fetching all of the characters and attributes,
    // readoutAddr should be 320
    while ( ~hVisEnd ) begin
      `TICK( clk );
    end
    `ASSERT( readoutAddr == 13'd320 );

    // advance to end of hsync pulse: readoutAddr should have been reset back to
    // the new row begin address, 160
    while ( ~hEndPulse ) begin
      `TICK( clk );
    end
    `ASSERT( readoutAddr == 13'd160 );

    $display( "All tests passed!" );
  end

endmodule
