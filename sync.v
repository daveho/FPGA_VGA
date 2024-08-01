// Sync module, based on Sync.pld from the HW_VGA project

module sync( // Inputs
             input nrst,
             input clk,
             input hBeginPulse,
             input hEndPulse,
             input vBeginPulse,
             input vEndPulse,
             input hCountEnd,
             input vCountZero,
             input hVisEnd,
             input vVisEnd,
             input vCountEnd,
             input vEndActive,
             // Outputs
             output hSync,
             output vSync,
             output hVis,
             output vVis,
             output nVis);

  // registers for registered outputs
  reg hSyncReg, vSyncReg, hVisReg, vVisReg;

  always @( posedge clk ) begin
    if ( nrst == 1'b0 ) begin
      // in reset: hSync and vSync are high,
      // hVis is true, vVis is false
      hSyncReg <= 1'b1;
      vSyncReg <= 1'b1;
      hVisReg <= 1'b1;
      vVisReg <= 1'b0;
    end else begin
      // not in reset

      // update hSyncReg if needed
      if ( hBeginPulse ) begin
        // begin hsync pulse
        hSyncReg <= 1'b0;
      end else if ( hEndPulse ) begin
        // end hsync pulse
        hSyncReg <= 1'b1;
      end

      // update vSyncReg if needed
      if ( vBeginPulse ) begin
        // begin vsync pulse
        vSyncReg <= 1'b0;
      end else if ( vEndPulse ) begin
        // end vsync pulse
        vSyncReg <= 1'b1;
      end

      // update hVisReg if needed
      if ( hCountEnd ) begin
        // beginning of horizontal visible region
        hVisReg <= 1'b1;
      end else if ( hVisEnd ) begin
        // end of horizontal visible region
        hVisReg <= 1'b0;
      end

      // update vVisReg if needed
      if ( hCountEnd & vCountZero ) begin
        // beginning of vertical visible region;
        // note that because the vertical count is incremented before
        // the end of the scanline, vcount is 0 when vertical visibility
        // begins, not 524
        vVisReg <= 1'b1;
      end else if ( hCountEnd & vVisEnd ) begin
        // end of vertical visible region
        vVisReg <= 1'b0;
      end
    end
  end

  // drive register outputs to corresponding module outputs
  assign hSync = hSyncReg;
  assign vSync = vSyncReg;
  assign hVis = hVisReg;
  assign vVis = vVisReg;

  // Active-low visibility signal:
  // if either hVis or vVis is not asserted,
  // then nVis is high (not asserted)
  assign nVis = ~hVis | ~vVis;

endmodule
