// Third attempt at implementing a VGA text mode display
// using an ICE40 FPGA

module icevga3( input nrst,
                input ext_osc,
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

  wire hSync, vSync, hVis, vVis, nVis;

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
                      .nVis( nVis ) );

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

  // for now: just generate a changing solid foreground, using the
  // vEndPulse signal to update 
  reg [9:0] count;

  always @( posedge clk ) begin
    if ( nrst == 1'b0 ) begin
      // in reset, clear counter
      count <= 10'd0;
    end else begin
      // increment counter when vEndPulse is asserted
      if ( vEndPulse ) begin
        count <= count + 10'd1;
      end
    end
  end

  // background color won't be used
  assign bgRed = 1'b0;
  assign bgGreen = 1'b0;
  assign bgBlue = 1'b0;
  assign bgIntense = 1'b0;

  // output foreground color always
  assign pixel = 1'b1;

  // use the high 4 bits of the counter to generate
  // the foreground color signals
  assign fgRed = count[6];
  assign fgGreen = count[7];
  assign fgBlue = count[8];
  assign fgIntense = count[9];

endmodule
