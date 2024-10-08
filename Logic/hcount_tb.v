// Testbench for hcount module

`include "testbench.vh"

module hcount_tb();

  `include "timing.vh"

  // Tick counter (used by  `TICK macro)
  integer ticks;

  // The testbench just needs to control -RST and CLK
  reg nrst, clk;

  // Outputs generated by the hcount module
  wire hCountEnd, hBeginPulse, hEndPulse, hVisEnd, hBeginActive, hEndActive;

  // instantiate hcount module
  hcount hcount_instance( .nrst( nrst ),
                          .clk( clk ),
                          .hCountEnd( hCountEnd ),
                          .hBeginPulse( hBeginPulse ),
                          .hEndPulse( hEndPulse ),
                          .hVisEnd( hVisEnd ),
                          .hBeginActive( hBeginActive ),
                          .hEndActive( hEndActive ) );

  initial begin
    // set tick count to 0
    ticks = 0;
    // generate dump file we can inspect using gtkwave
    $dumpfile( "hcount_tb.vcd" );
    $dumpvars;
  end

  integer i; // loop counter

  initial begin
    // generate a reset pulse
    `RESET( nrst, clk );

    // module is now out of reset

    // simulate 800 cycles (one scanline), checking outputs
    // to make sure they're right
    for ( i = 0; i < 800; i++) begin
      // Check that output values are correct
      `ASSERT( hCountEnd == ( i == H_COUNT_END ) );
      `ASSERT( hBeginPulse == ( i == H_BEGIN_PULSE ) );
      `ASSERT( hEndPulse == ( i == H_END_PULSE ) );
      `ASSERT( hVisEnd == ( i == H_VIS_END ) );
      `ASSERT( hBeginActive == ( i == H_BEGIN_ACTIVE ) );
      `ASSERT( hEndActive == ( i == H_END_ACTIVE ) );

      // Generate one clock pulse
      `TICK( clk );
    end

    // If we got here, all of the test assertions succeeded
    $display( "All tests passed!" );
  end

endmodule
