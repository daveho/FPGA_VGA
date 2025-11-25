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
//   Arduino D14: pushbutton input (0=pressed), used to start the tests
//   Arduino D15: output to green LED (if tests pass)
//   Arduino D16: output to red LED (if tests fail)

#define PIN_SER_DATA  8
#define PIN_SER_CLK   9
#define PIN_SER_RCLK  10
#define PIN_NR        11
#define PIN_NW        12
#define PIN_NRST      13
#define PIN_BTN       14
#define PIN_GREEN_LED 15
#define PIN_RED_LED   16

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
  DDRD = 0xFF; // set port D pins to output
  PORTD = byte;
  digitalWrite( PIN_NW, LOW );
  digitalWrite( PIN_NW, HIGH );
}

uint8_t readVRAM( uint16_t addr ) {
  setAddr( addr );
  DDRD = 0x00;  // set port D pins to input
  PORTD = 0x00; // no pull-ups
  uint8_t data;
  digitalWrite( PIN_NR, LOW ); // start read pulse
  data = PIND; // read byte from data bus
  digitalWrite( PIN_NR, HIGH ); // end read pulse

  // set PORTD pins back to output:
  // avoids leaving the bus transceiver A-side inputs floating
  DDRD = 0xFF;

  return data;
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
#define ATTR( fg, bg ) ((bg)|((fg) << 4 ))

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

#define HELLO_TEXT_ADDR 2314

// Check the result of clearing the display:
// every character should be set to space, and every
// attribute should be set to fg=GRAY bg=BLACK.
bool checkDisplayClear( bool good ) {
  uint16_t addr = 0;
  uint8_t val;
  for ( int i = 0; i < 2400; ++i ) {
    val = readVRAM( addr++ );
    if ( val != ' ' )
      good = false;
    val = readVRAM( addr++ );
    if ( val != ATTR(GRAY,BLACK) )
      good = false;
  }

  return good;
}

// Check that the "Hello!" text was written correctly.
bool checkHelloText( bool good ) {
  const char expected[] = "Hello!";
  uint16_t addr = HELLO_TEXT_ADDR;
  uint8_t val;
  for ( int i = 0; i < 6; ++i ) {
    val = readVRAM( addr++ );
    if ( val != expected[i] )
      good = false;
    val = readVRAM( addr++ );
    if ( val != ATTR(YELLOW|INTENSE, BLUE) )
      good = false;
  }
  return good;
}

// Display a test pattern
void testPattern() {
  uint8_t ch = 0;
  uint8_t attr = 0;
  uint16_t addr = 0;

  for ( int i = 0; i < 2400; ++i ) {
    writeVRAM( addr++, ch++ );
    writeVRAM( addr++, attr++ );
  }
}

// Check that VRAM contains expected contents of test pattern
bool checkTestPattern( bool good ) {
  uint8_t expected_ch = 0;
  uint8_t expected_attr = 0;
  uint16_t addr = 0;

  for ( int i = 0; i < 2400; ++i ) {
    uint8_t val;
    val = readVRAM( addr++ );
    if ( val != expected_ch )
      good = false;
    ++expected_ch;
    val = readVRAM( addr++ );
    if ( val != expected_attr )
      good = false;
    ++expected_attr;
  }

  return good;
}

void successDisplay() {
  clearDisplay();
  displayText( 1022, "All tests passed!", ATTR(GREEN|INTENSE, BLACK) );
  displayText( 2588, "Writing to VRAM and reading from VRAM appear to work", ATTR(YELLOW|INTENSE, BLUE) );
  displayText( 2942, "LET'S FRICKIN' GO", ATTR(CYAN|INTENSE, BLACK) );
}

void runTests() {
  // turn off green and red LEDs
  digitalWrite( PIN_GREEN_LED, LOW );
  digitalWrite( PIN_RED_LED, LOW );

  // Generate a reset pulse for the display controller
  digitalWrite( PIN_NRST, LOW );
  delay( 1 );
  digitalWrite( PIN_NRST, HIGH );

  bool good = true;

  clearDisplay();
  good = checkDisplayClear( good );
  displayText( 2314, "Hello!", ATTR(YELLOW|INTENSE, BLUE) );
  good = checkHelloText( good );

  delay( 1000 ); // let hello message be visible for one second

  testPattern();

  delay( 1000 ); // let test pattern be visible for one second

  // If tests passed, display success text
  if ( good )
    successDisplay();

  // Turn on green or red LED
  digitalWrite( good ? PIN_GREEN_LED : PIN_RED_LED, HIGH );

  // wait for a bit
  delay( 10 );
}

void setup() {
  // Initial state

  // PORTD configured as output
  // D8-D13 configured as output
  // D14 configured as input with pullup
  // D15-D16 configured as output

  DDRD = 0xFF;
  pinMode( PIN_SER_DATA, OUTPUT );
  pinMode( PIN_SER_CLK, OUTPUT );
  pinMode( PIN_SER_RCLK, OUTPUT );
  pinMode( PIN_NR, OUTPUT );
  pinMode( PIN_NW, OUTPUT );
  pinMode( PIN_NRST, OUTPUT );
  pinMode( PIN_BTN, INPUT_PULLUP );
  pinMode( PIN_GREEN_LED, OUTPUT );
  pinMode( PIN_RED_LED, OUTPUT );

  // Drive serial data and register clocks low
  digitalWrite( PIN_SER_CLK, LOW );
  digitalWrite( PIN_SER_RCLK, LOW );

  // De-assert -R, -W, -RST
  digitalWrite( PIN_NR, HIGH );
  digitalWrite( PIN_NW, HIGH );
  digitalWrite( PIN_NRST, HIGH );

  // Turn off LEDs
  digitalWrite( PIN_GREEN_LED, LOW );
  digitalWrite( PIN_RED_LED, LOW );

  // Wait for a bit
  delay( 2 );
}

void loop() {
  for (;;) {
    if ( digitalRead( PIN_BTN ) == LOW ) {
      // button pressed, so run the tests
      runTests();
    }
  }
}
