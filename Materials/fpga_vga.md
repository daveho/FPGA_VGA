---
title: "Episode 5 (Hardware VGA, FPGA edition!)"
aspectratio: 169
colorlinks: true
pandoc-beamer-block:
  - classes: [info]
  - classes: [alert]
    type: alert
header-includes:
  - \usepackage{graphbox}
  - \usepackage[export]{adjustbox}
  - \usepackage[absolute,overlay]{textpos}
  - \usecolortheme{orchid}
---

## Hello again! {.t}

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

But...I now had a working design `\pause`{=latex}

* **Maybe I could translate it to Verilog** `\pause`{=latex}

TL;DR I translated the design to Verilog `\pause`{=latex}

This video: `\pause`{=latex}

* Translating the design to Verilog (the easy parts) `\pause`{=latex}
* Host interface (initially got stuck here, then
  learned about an easy workaround) `\pause`{=latex}
* Demo `\pause`{=latex}
* Next steps
