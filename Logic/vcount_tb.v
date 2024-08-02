// Testbench for vcount module

`include "testbench.vh"

module vcount_tb();

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

  integer i; // loop counter

  initial begin
    // set tick count to 0
    ticks = 0;
/*
    // generate dump file we can inspect using gtkwave
    $dumpfile( "vcount_tb.vcd" );
    $dumpvars;
*/

    // generate a reset pulse
    `RESET( nrst, clk );

    // both hcount and vcount are now out of reset

    `ASSERT( vCount == V_COUNT_INITIAL_VAL );

    // generate enough ticks to take us to the end of the hsync pulse:
    // this is just before the vertical count will be incremented
    `GENCLOCK( H_END_PULSE, clk );
    `ASSERT( vCount == V_COUNT_INITIAL_VAL );

    // generate one clock pulse: this should increment the vertical count
    `TICK( clk );
    `ASSERT( vCount == V_COUNT_INITIAL_VAL + 12'd1 );

    // advance time until vCount == V_BEGIN_PULSE
    while ( vCount != V_BEGIN_PULSE ) begin
      `TICK( clk );
    end

    // vBeginPulse should not be asserted yet: that will happen
    // when the horizontal counter reaches the end
    `ASSERT( vBeginPulse == 1'b0 );

    // advance time until hCountEnd is asserted: when this happens,
    // vBeginPulse should also be asserted
    while ( ~hCountEnd ) begin
      `TICK( clk );
    end

    // vertical count should be the same as before
    `ASSERT( vCount == V_BEGIN_PULSE );

    // vBeginPulse should be asserted
    `ASSERT( vBeginPulse );

    // vBeginPulse should only be asserted for one cycle
    `TICK( clk );
    `ASSERT( ~vBeginPulse );

    // advance time until vEndPulse is asserted
    while ( ~vEndPulse ) begin
      `TICK( clk );
    end

    // vEndPulse should only be asserted for one cycle
    `TICK( clk );
    `ASSERT( ~vEndPulse );

    // Now that we've observed the pulse generation timing events, which are
    // synchronized to hCountEnd, we can run through the other vertical
    // timing signals, which are just combinational outputs asserted when
    // the vertical count matches an expected value. By running them through
    // in order, we should go through slighly less than 1 frame of clock cycles.

    // advance to vCountEnd
    while ( ~vCountEnd ) begin
      `TICK( clk );
    end
    `ASSERT( vCount == V_COUNT_END );

    // advance to vCountZero
    while ( ~vCountZero ) begin
      `TICK( clk );
    end
    `ASSERT( vCount == V_COUNT_ZERO );

    // advance to vVisEnd
    while ( ~vVisEnd ) begin
      `TICK( clk );
    end
    `ASSERT( vCount == V_VIS_END );

    // advance until vertical count returns to initial value - 1
    // and hCountEnd is asserted. This should be exactly one
    // frame's worth of ticks, minus 1 (since this is the end of
    // a scanline, and out of reset we start at the beginning of
    // a scanline)
    while ( ( vCount != V_COUNT_INITIAL_VAL ) | ~hCountEnd ) begin
      `TICK( clk );
    end
    //$display( "final ticks: %d", ticks );
    `ASSERT( ticks == (TICKS_PER_SCANLINE * SCANLINES_PER_FRAME) - 1 );

    $display( "All tests passed!" );

  end

endmodule
