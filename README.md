This repository contains the code for my verilog-based windowed standard deviation filter. It was developed for use on the Red Pitaya DAQ development board. Please see the LICENSE file for license information. It is intended for use in situations where the standard deviation of a fast signal is needed in real-time, ie noise characterisation, event detection and oscilloscope triggering.

The exact performance of the filter depends on your target FPGA. In my testing on the Red Pitaya (Zynq 7010, lowest speed grade), it ran at 125Msamples/sec which is the maximum clock speed for the ADCs on the board. 

The top level module can be found in `standard_deviation/hdl/standard_deviation.v`. All test benches were written in python using cocotb.

Contents:
 - `fifo/`: A simple, vendor-independent FIFO implementation
 - `include/`: Contains some functions used at synthesis time to allow module generalisation
 - `sqrt/`: A fixed-point square root implementation using cascaded blocks of the `sqrt_remainder` module
 - `sqrt_remainder/`: A module which implements a single iteration of the non-restoring sqrt algorithm
 - `standard_deviation/`: The top level module
 - `variance/`: A module which implements a windowed standard deviation filter