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


void setup() {
  // put your setup code here, to run once:

}

void loop() {
  // put your main code here, to run repeatedly:

}
