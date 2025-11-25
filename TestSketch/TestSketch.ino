// Test program for VGA display

// There are 2 74HC595 shift registers used to generate
// the address for display VRAM reads/writes

// Connections
//   Arduino D[7:0] (AVR PORTD) connected to display data bus (D[7:0])
//     Allows reading and writing bytes of data from/to the display VRAM
//   Arduino D8: connected to serial data input of first shift register
//   Arduino D9: serial clock output to shift registers
//     (data shifted on positive edge)
//   Arudino D10: register clock output to shift register
//     (data clocked into output registers on positive edge)
//   Arduino D11: output to display -R (read strobe)
//   Arduino D12: output to display -W (write strobe)
//   Arduino D13: output to display -RST (reset)

#define PIN_SER_DATA 8
#define PIN_SER_CLK  9
#define PIN_SER_RCLK 10
#define PIN_NR       11
#define PIN_NW       12
#define PIN_NRST     13

void setup() {
  // Initial state

  // PORTD configured as output
  // D8-D13 configured as output

  DDRD = 0xFF;
  pinMode( PIN_SER_DATA, OUTPUT );
  pinMode( PIN_SER_CLK, OUTPUT );
  pinMode( PIN_SER_RCLK, OUTPUT );
  pinMode( PIN_NR, OUTPUT );
  pinMode( PIN_NW, OUTPUT );
  pinMode( PIN_NRST, OUTPUT );

  // Drive serial data and register clocks low
  digitalWrite( PIN_SER_CLK, LOW );
  digitalWrite( PIN_SER_RCLK, LOW );

  // De-assert -R, -W, -RST
  digitalWrite( PIN_NR, HIGH );
  digitalWrite( PIN_NW, HIGH );
  digitalWrite( PIN_NRST, HIGH );

  // Wait for a bit
  delay( 2 );

  // Generate a reset pulse for the display controller
  digitalWrite( PIN_NRST, LOW );
  delay( 1 );
  digitalWrite( PIN_NRST, HIGH );
}

void loop() {
  // put your main code here, to run repeatedly:

}
