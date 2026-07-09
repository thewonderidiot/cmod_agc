# cmod_agc

This repository combines [agc_monitor](https://github.com/thewonderidiot/agc_monitor) and [agc_simulation](https://github.com/virtualagc/agc_simulation) into a single FPGA project, targeted at the small and relatively-cheap [Cmod A7-35T](https://digilent.com/shop/cmod-a7-35t-breadboardable-artix-7-fpga-module/). It is intended to greatly simplify the process of putting a Monitor-capable hardware AGC simulation into a project.

Due to BRAM limitations, some concessions had to be made. Queues are generally shorter all around (although this doesn't appear to have caused any problems that I've found, yet); instruction trace history is much shorter; and banks 44 through 77 can not be used for core rope simulation.

## Building

Requirements:
* [AMD Vivado](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html) 
* [openFPGALoader](https://github.com/trabucayre/openFPGALoader).


To build the FPGA, first source the Vivado settings for your installation, then run `make`. If interfacing with external hardware, the build type can optionally be specified with the `BUILD_TYPE` make variable. 

Supported `BUILD_TYPE`s:
* `AGC` - Standard build with no additional I/O.
* `CDU` - All interfaces required to drive the CDU and PSA.

```
source /opt/Xilinx/Vivado/2024.1/settings64.sh
make BUILD_TYPE=CDU
```

Once built, the bitstream can be loaded onto the board by running:
```
make load
```
