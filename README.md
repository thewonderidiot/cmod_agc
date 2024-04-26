# cmod_agc

This repository combines [agc_monitor](https://github.com/thewonderidiot/agc_monitor) and [agc_simulation](https://github.com/virtualagc/agc_simulation) into a single FPGA project, targeted at the small and relatively-cheap [Cmod A7-35T](https://digilent.com/shop/cmod-a7-35t-breadboardable-artix-7-fpga-module/). It is intended to greatly simplify the process of putting a Monitor-capable hardware AGC simulation into a project.

Due to BRAM limitations, some concessions had to be made. Queues are generally shorter all around (although this doesn't appear to have caused any problems that I've found, yet); instruction trace history is much shorter; and _at most_ only three rope modules can be installed in the AGC itself. Aurora 88 is included and configured to serve this role. It is expected that other programs will be injected via the CRS capability of the Monitor.
