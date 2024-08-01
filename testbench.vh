// Common definitions for testbenches


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
    $display( "%s:%0d %m time:%5t ASSERTION FAILED: cond", `__FILE__, `__LINE__, $time ); \
    $finish; \
  end

// vim:ft=verilog:
