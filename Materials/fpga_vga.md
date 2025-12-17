---
title: "Episode 5 (Hardware VGA, FPGA edition!)"
aspectratio: 169
colorlinks: true
pandoc-beamer-block:
  - classes: [info]
  - classes: [alert]
    type: alert
pandoc-latex-fontsize:
  - classes: [small]
    size: small
  - classes: [footnotesize]
    size: footnotesize
  - classes: [scriptsize]
    size: scriptsize
header-includes:
  - \usepackage{graphbox}
  - \usepackage[export]{adjustbox}
  - \usepackage[absolute,overlay]{textpos}
  - \usecolortheme{orchid}
---

## Hello again! {.t}

Since 2016, I've been working on a 6809-based microcomputer system `\pause`{=latex}

Summer 2024[^*]: I made a VGA text display using GALs,
dual port static RAMs, and 7400-series logic chips `\pause`{=latex}

Validated the design by simulating in Logisim Evolution `\pause`{=latex}

Got it to work! `\pause`{=latex}

Lots of fun, great learning experience `\pause`{=latex}

*Not very practical* `\pause`{=latex}

* Resulting design has 25 ICs, including two
  52-pin PLCC packages `\pause`{=latex}
* Even using surface mount ICs, very challenging
  to fit on 15cm by 9cm PCB

[^*]: In North America

## Use an FPGA? {.t}

The obvious move would be to use an FPGA `\pause`{=latex}

I've stuggled for *years* to learn FPGAs well enough to make
a display controller `\pause`{=latex}

But...I now had a working design, even if not
an FPGA-based design `\pause`{=latex}

* **Maybe I could translate it to Verilog** `\pause`{=latex}

TL;DR I translated the design to Verilog `\pause`{=latex}

This video: `\pause`{=latex}

* Translating the design to Verilog (the easy parts) `\pause`{=latex}
* Host interface (initially got stuck here, then
  learned about an easy workaround) `\pause`{=latex}
* Demo `\pause`{=latex}
* Next steps `\pause`{=latex}

As always, links to the code and schematic are in the video description.

## Modules {.t}

The original design had 6 modules, each implemented as a GAL
(or two GALs in the case of the pixel generator) and,
where necessary, supporting ICs:

Module              | GAL equations
------------------- | -------------
Horizontal count    | HCntCtrl.pld
Vertical count      | VCntCtrl.pld
Sync generation     | Sync.pld
Readout address gen | ROutCtrl.pld
VRAM                | VRAMCtrl.pld
Pixel gen           | PxGnCtrl.pld, ShiftReg.pld

## Modules (FPGA) {.t}

In the FPGA version of the design, each module is implemented
by one Verilog module:

Module              | GAL equations               | Verilog
------------------- | --------------------------- | -----------
Horizontal count    | HCntCtrl.pld                | hcount.v
Vertical count      | VCntCtrl.pld                | vcount.v
Sync generation     | Sync.pld                    | sync.v
Readout address gen | ROutCtrl.pld                | readout.v
VRAM                | VRAMCtrl.pld                | vram\_mirrored.v
Pixel gen           | PxGnCtrl.pld, ShiftReg.pld  | pixgen.v

`\pause`{=latex} To convert the design to Verilog, I translated the
logic in the original GAL equations and the supporting ICs to
equivalent Verilog constructs in the most direct way possible.

## Converting to Verilog {.t}

General approach to conversion to Verilog:`\pause`{=latex}

Original Design | Verilog
--------------- | --------------- 
GAL registers, 7400 series registers (e.g., 74ALS273) | `reg` instances
Counters (e.g., 74ALS163)            | `reg` instances (Verilog supports addition!)
Clock data into a flip flop          | Nonblocking assignment in `always` block
Dual port RAM (IDT7134)              | Array of 8-bit registers inferred as BRAM
Font ROM (27SF512)                   | 4 KB of pre-initialized block RAM
Module inputs and outputs            | Module inputs and outputs

`\pause `{=latex} Overall, this wasn't too hard!

<!--
* GAL registers and 7400 series registers (e.g., 74ALS273)
  become Verilog registers (`reg` instances) `\pause`{=latex}
* Counters (e.g., 74ALS163) also become Verilog registers
  (because Verilog supports addition, e.g. `addr + 13'd1;`)
  `\pause`{=latex}
* Clocking data into a flip flop becomes a nonblocking assignment
  in an `always @( posedge clk )` block `\pause`{=latex}
* An array of 8-bit vectors with suitable read and write signaling
  will be inferred as block RAM: takes place of dual port static
  RAM (IDT7134) `\pause`{=latex}
* Input and output pins become module input and output wires
-->

## Example: Horizontal Count module {.t}

The horizontal count module counts the horizontal pixels in each
scanline, and generates appropriate timing signal needed by
the vertical count and sync generation modules

In the original implementation:

* 3x 74ALS163 4-bit counters
* GAL for control and timing`\\`{=latex}
  signal generation

`\vfill`{=latex}

Example timing signal: horizontal count`\\`{=latex}
end (true if horizontal count value is at`\\`{=latex}
maximum for scanline)

``` { .scriptsize }
; HCOUNT_END is when HCOUNT=799 (1100011111 binary)
HCEND   = HC9 * HC8 * /HC7 * /HC6 * /HC5 * HC4 * HC3 * HC2 * HC1 * HC0
```

## Example: Horizontal Count module {.t}

In Verilog: define a 12-bit register, reset or increment it as needed:

```verilog { .scriptsize }
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
```

Generating a control signal:

```verilog { .scriptsize }
assign hCountEnd = (count == H_COUNT_END);
```

## Example: Sync module {.t}

The Sync module uses control signals generated by the horizontal
and vertical count modules to generate to generate VGA horizontal
and vertical sync signals, as well as visibility and ``activity''
signals needed by the pixel generator and readout modules.

In the original implementation, it's a single GAL22V10
with registered outputs.

`\vfill`{=latex}

Example timing signal: VGA vertical sync

``` { .scriptsize }
; Vertical sync:
;   - if /NRST is asserted, next VSync should be high
;   - if VEPulse is asserted, next VSync should be high
;   - if neither VBPulse nor VEPulse is asserted, next VSync value
;     should be the same as the current one
VSync.R =   /NRST
          + VEPulse
          + /VBPulse * /VEPulse * VSync
```

## Example: Sync module {.t}

In Verilog, generated outputs are `reg` instances:

```verilog { .scriptsize }
// registers for registered outputs
reg hSyncReg, vSyncReg, hVisReg, vVisReg, vActiveReg;
```

Their contents are updated on each positive clock edge:

```verilog { .scriptsize }
// Note: only showing vSyncReg updates
always @( posedge clk ) begin
  if ( nrst == 1'b0 ) begin
    vSyncReg <= 1'b1; // in reset
  end else begin
    // update vSyncReg if needed
    if ( vBeginPulse ) begin
      vSyncReg <= 1'b0; // begin vsync pulse
    end else if ( vEndPulse ) begin
      vSyncReg <= 1'b1; // end vsync pulse
    end
  end
end
```

## Example: Readout module {.t}

::: columns

:::: column

::::: {.small}
The Readout module generates the VRAM addresses of the character
and attribute values needed to generate the pixels for each visible
scanline.

Original implementation: 3 74ALS163 counters (current address),
2 74ALS273 registers (row begin address), GAL22V10 for control.

* Row of characters = 160 bytes (80 char/attr pairs)
* Characters are 8 pixels wide
* Update readout addr every 4 pixels
* Same sequence of addresses for each
  scanline in a character row

Annoyance: VRAM addresses are 13 bits, so the GAL generates the
MSB of the current address. (Each '163 is only 4 bits.)

:::::

::::

:::: column

`{\ }`{=latex}

::::

:::

## Example: Readout module {.t}

In Verilog, the row begin address and current (readout) address
are just 13 bit registers:

```verilog { .scriptsize }
reg [12:0] rowBeginAddrReg;
reg [12:0] readoutAddrReg;
```

Conditionally update their values according to current control
signal values:

```verilog { .scriptsize }
// Example logic: update rowBeginAddrReg or readoutAddrReg
// at end of scanline (when hSync pulse starts)
if ( vActive & hBeginPulse ) begin
  if ( vCount == 4'b1111 ) begin
    // We've reached the last pixel row in the current character row,
    // so set the row begin address to the current readout address
    // (in order to start the next character row)
    rowBeginAddrReg <= readoutAddrReg;
  end else begin
    // The next pixel row will be part of the same character row,
    // so set the readout address back to the current value of the
    // row begin address register.
    readoutAddrReg <= rowBeginAddrReg;
  end
end
```
