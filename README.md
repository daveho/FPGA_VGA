# FPGA VGA text display

This is a companion project to the [HW\_VGA](https://github.com/daveho/HW_VGA) project.
Its goal is to implement an 80x30 text display using 640x480 VGA, using more or less
the same approach as the HW\_VGA project, but using a
[Lattice UP5K FPGA](https://www.latticesemi.com/en/Products/FPGAandCPLD/iCE40UltraPlus)
on an [Upduino 3.1](https://tinyvision.ai/products/upduino-v3-1) (or 3.0) board
rather than discrete logic, GALs, and dual port static RAM.

The current status is that I can produce a valid 640x480 VGA signal displaying
a solid color, and I've written some test benches, including one for the readout
module (which generates the addresses of characters and attributes to fetch from
video memory.)

The [Schematic](Schematic) directory has a KiCad schematic, and the
[Logic](Logic) directory has the Verilog code for the FPGA. I use
[APIO](https://github.com/FPGAwars/apio) as the front end for the FPGA tools (see my
[blog post about using the Upduino 3 on Linux](https://daveho.github.io/2021/02/07/upduino3-getting-started-on-linux.html)
for details on setting things up.)

Acknowledgment: a viewer of one of my youtube videos recommended
[John Winans's youtube channel](https://www.youtube.com/channel/UCik0xMsb7kSpPUvT2JoJQ1w)
as a good starting point for learning about FPGA development.
His [introduction to simulation](https://youtu.be/xZhl64vHJ-E)
and [his Verilog examples repo](https://github.com/johnwinans/Verilog-Examples) were
incredibly helpful. By applying the techniques covered in the simulation video, I
basically went from having no idea how to simulate designs to being able to write
some halfway-reasonable testbenches in a day or two. Thank you, John!

Stay tuned!
