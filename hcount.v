// Horizontal count module: based on HCntCtrl.pld (the GAL used to control
// the horizontal timing in the HW_VGA project)

module hcount(input nrst,
              input clk,
              output hCountEnd,
              output hBeginPulse,
              output hEndPulse,
              output hVisEnd,
              output hBeginActive,
              output hEndActive);

  reg [11:0] count;

  always @(posedge clk) begin
    if ( nrst == 1'b0 ) begin
      // in reset, clear the counter
      count <= 12'd0;
    end else begin
      // not in reset, either advance count by 1 or reset to 0 (if at end of scanline)
      if ( hCountEnd )
        count <= 12'd0;
      else
        count <= count + 12'd1;
    end
  end

  // Timing outputs
  assign hCountEnd = (count == 12'd799);
  assign hBeginPulse = (count == 12'd655);
  assign hEndPulse = (count == 12'd751);
  assign hVisEnd = (count == 12'd639);
  assign hBeginActive = (count == 12'd793);
  assign hEndActive = (count == 12'd633);

endmodule
