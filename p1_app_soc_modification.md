# P1 App SoC Modification #

This document provides an overview of how to use Vivado to modify the p1-app SoC. This focuses on project-specific knowledge and leaves the reader to use Xilinx documentation for general Vivado flow knowledge.

## Useful resources: ##
* [UG994](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_1/ug994-vivado-ip-subsystems.pdf): Designing IP Subsystems Using IP Integrator
* [riscv-fpga-software-dev](https://gitlab-ext.galois.com/mwaugaman1/riscv-fpga-software-dev): Developing Software on the GFE

## Basic steps to add a component ##
1. Increase the number of masters in the AXI interconnect block by 1. Set the `Enable Register Slice` setting to `Outer and Auto`. This adds register slices to help with timing.
2. Add the component to the block diagram and wire the necessary connections. You may need to add I/O buffers as described in the I/O Buffers section below.
3. If the component needs interrupt functionality, connect it to the xlconcat_0 block, which is wired to the PLIC in the SSITH processor.
4. Set the address of the component in the Address Editor. This is detailed below.
5. Add the pins and voltage levels of the I/O to the `vcu118_soc.xdc` constraints file.
6. Validate design.
7. Generate the bitstream.

Make sure to save your changes to the design by running `write_bd_tcl -force $GFE_REPO/tcl/soc_bd.tcl` in the TCL Console.

## Changing the address map ##
There are 2 sections in the Address Editor: the SSITH processor and the AXI DMA. Every entry under both of these where the component name shows up needs to be changed to the desired address. The DMA has access to only DDR, and none of the other components, so every component except for DDR should be in the Excluded Address Segments section. However to change the address of a component, it must be included, changed, and then excluded again.

## Component specifics ##

An explanation of how components are configured and why.

### I/O Buffers ###
Some Xilinx components like the SPI and IIC require adding bidirectional I/O buffers.
You can tell when adding these is necessary because the I/O on the block will have names like `sda_t`, `sda_o` and `sda_i`.
The name of this component is `iobuf_v1_0` and can be added like any other IP component. This is because this component, which uses the Xilinx primitive IOBUF, has already been added to the project IP Catalog by going through the `Create and Package New IP` steps.

### SPI ###
The important AXI Quad SPI settings to note are the Frequency Ratio and the FIFO Depth.
Since we have connected the `ext_spi_clk` to the `s_axi_clk`, the SPI clock will be the `s_axi_clk` divided by the Frequency Ratio. At the time of writing, the AXI clock was 50MHz and the Frequency Ratio was set to 8 for a SPI clock of 12.5MHz. This has not been tested with an SD card.
The FIFO Depth has been set to 256 for use with an SD card to prevent data loss.

### IIC ###
The IIC SCL clock frequency is set to 100kHz for use with the display.

## Generating the bitstream ###
When generating a bitstream for the p1-app SoC, the Implementation Strategy should be set to "Vivado Implementation Defaults". This is because faster strategies such as "Flow_RuntimeOptimized" result in route conflicts.
This strategy can be changed in Flow Navigator -> Project Manger -> Settings -> Project settings -> Implementation -> Options -> Strategy. The strategy is originally set when the project is first built, and this can be changed by modifying impl_1’s strategy in `tcl/soc.tcl` (this has already been changed in the `pl-app` branch of the gfe.

## Merging in changes from `develop` ##
Right now the method of merging in major changes to the block design from the `develop` branch is building a new project from the `develop ` block design and then re-adding the `p1-app` components. It's recommended to save your original project with another name so that you can refer back to it when adding to the `develop` block diagram. Actually merging the two block designs is made difficult by Vivado's formatting of the `soc_bd.tcl` and pickiness about hierarchy. But if you are able to merge without having to recreate the block design, definitely do that.