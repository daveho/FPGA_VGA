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

// Set the display address.
void setAddr( uint16_t addr ) {
  // address bits are sent to shift register from MSB to LSB
  for ( int i = 0; i < 16; ++i ) {
    int bit = ( addr & 0x8000 ) != 0 ? HIGH : LOW;
    // output the bit
    digitalWrite( PIN_SER_DATA, bit );
    // clock it in
    digitalWrite( PIN_SER_CLK, HIGH );
    digitalWrite( PIN_SER_CLK, LOW );
    // go to next bit
    addr <<= 1;
  }
  // Clock data into the output register
  digitalWrite( PIN_SER_RCLK, HIGH );
  digitalWrite( PIN_SER_RCLK, LOW );
}

void writeVRAM( uint16_t addr, uint8_t byte ) {
  setAddr( addr );
  PORTD = byte;
  digitalWrite( PIN_NW, LOW );
  digitalWrite( PIN_NW, HIGH );
}

#define BLACK   0
#define RED     1
#define GREEN   2
#define YELLOW  3
#define BLUE    4
#define MAGENTA 5
#define CYAN    6
#define GRAY    7
#define INTENSE 8
#define ATTR( fg, bg ) (bg|(fg << 4 ))

// Display text, starting at specified VRAM address
void displayText( uint16_t addr, const char *s, uint8_t attr ) {
  while ( *s != '\0' ) {
    char c = *s;
    ++s;
    writeVRAM( addr, c );
    ++addr;
    writeVRAM( addr, attr );
    ++addr;
  }
}

// Clear the display
void clearDisplay() {
  uint16_t addr = 0;
  for ( int16_t i = 0; i < 2400; ++i ) {
    writeVRAM( addr++, ' ' );
    writeVRAM( addr++, ATTR(GRAY, BLACK) );
  }
}

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

  clearDisplay();
  displayText( 2314, "Hello!", ATTR(GRAY, BLACK) );
}

void loop() {
  // put your main code here, to run repeatedly:

}
