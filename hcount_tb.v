// Testbench for hcount module

// Assume that #1 advances time by 10ns.
// The test bench will use #1 to mean one clock cycle,
// which would be a 100 MHz clock, even though in reality
// the dot clock is 25.175 MHz.
`timescale 10ns/1ns

// John Winans's tutorials (https://github.com/johnwinans/Verilog-Examples)
// recommend this
`default_nettype none

// Test assertion macro (stolen from John Winans's tutorials)
`define ASSERT(cond) \
  if ( ~(cond) ) begin \
    $display( "s:%0d %m time:%5t ASSERTION FAILED: cond", `__FILE__, `__LINE__, $time ); \
    $finish; \
  end

module hcount_tb();

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
    // generate dump file we can inspect using gtkwave
    $dumpfile( "hcount_tb.vcd" );
    $dumpvars;
  end

  integer i; // loop counter

  initial begin
    // generate a reset pulse
    nrst = 0;
    clk = 0;
    #1;
    clk = 1;
    #1;
    nrst = 1;
    clk = 0;
    #1;

    // module is now out of reset

    // simulate 800 cycles (one scanline), checking outputs
    // to make sure they're right
    for ( i = 0; i < 800; i++) begin
      // Check that output values are correct
      `ASSERT( hCountEnd == ( i == 799 ) );
      `ASSERT( hBeginPulse == ( i == 655 ) );
      `ASSERT( hEndPulse == ( i == 751 ) );
      `ASSERT( hVisEnd == ( i == 639 ) );
      `ASSERT( hBeginActive == ( i == 793 ) );
      `ASSERT( hEndActive == ( i == 633 ) );

      // Generate one clock pulse
      clk = 1;
      #1;
      clk = 0;
      #1;
    end

    // If we got here, all of the test assertions succeeded
    $display( "All tests passed!" );
  end

endmodule
