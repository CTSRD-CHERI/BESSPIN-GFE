```
This material is based upon work supported by the Defense Advanced
Research Project Agency (DARPA) under Contract No. HR0011-18-C-0013. 
Any opinions, findings, conclusions or recommendations expressed in
this material are those of the author(s) and do not necessarily
reflect the views of DARPA.

Distribution Statement "A" (Approved for Public Release, Distribution
Unlimited)
```

# BESSPIN Government Furnished Equipment (GFE) #

Source files and build scripts for generating and testing the BESSPIN GFE.

Please refer to the [GFE System Description pdf](GFE_Rel5.2_System_Description.pdf)
for a high-level overview of the system.

## Table of contents ##

- [Getting Started](#getting-started)
  - [Setup OS (Debian Buster)](#setup-os-debian-buster)
  - [Install Vivado](#install-vivado)
  - [Clone this Repo](#clone-this-repo)
  - [Update Dependencies](#update-dependencies)
  - [Configure Network](#configure-network)
  - [Building the Bitstream](#building-the-bitstream)
  - [Storing a Bitstream in Flash](#storing-a-bitstream-in-flash)
  - [Testing](#testing)
- [Simulation](#simulation)
- [Manually Running FreeRTOS](#manually-running-freertos)
  - [Running FreeRTOS + TCP/IP stack](#running-freertos-tcp-ip-stack)
- [Running Linux - Debian or Busybox](#running-linux-debian-or-busybox)
  - [Creating Debian Image](#creating-debian-image)
  - [Creating Busybox Image](#creating-busybox-image)
    - [Build the memory image](#build-the-memory-image)
    - [Load and run the memory image](#load-and-run-the-memory-image)
  - [Using Ethernet on Linux](#using-ethernet-on-linux)
  - [Storing a boot image in Flash](#storing-a-boot-image-in-flash)
- [Adding in Your Processor](#adding-in-your-processor)
  - [Modifying the GFE](#modifying-the-gfe)
- [Rebuilding the Chisel and Bluespec Processors](#rebuilding-the-chisel-and-bluespec-processors)
- [Tandem Verification](#tandem-verification)
  - [Establishing the PCIe Link](#establishing-the-pcie-link)
  - [Installing Bluespec](#installing-bluespec)
  - [Licensing](#licensing)
  - [Capturing a Trace](#capturing-a-trace)
  - [Comparing a Trace](#comparing-a-trace)
- [PCI Express Root Complex](#pci-express-root-complex)
  - [Hardware Setup](#pcie-hardware-setup)
  - [Reset](#pcie-reset)
  - [Testing](#pcie-testing)

## Getting Started ##

To update from a previous release, please follow the instructions
below, starting with [Update Dependencies](#update-dependencies).

Pre-built images are available in the `bitstreams` folder.  Use these,
if you want to quickly get started.  This documentation walks through
the process of building and testing a bitstream.  It suggests how to
modify the GFE with your own processor.

### Setup OS (Debian Buster) ###

Before installing the GFE for the first time, please perform a clean
install of [Debian 10 ("Buster")](https://www.debian.org/releases/buster/)
on the development and testing hosts.  This is the supported OS for
building and testing the GFE.

### Install Vivado ###

Download and install **Vivado 2019.1**.  This is a change from
previous versions of the GFE, which used Vivado 2017.4.  The new
version is needed to support bitstream generation for designs using
the PCIe bus.  A license key for the tool is included on a piece of
paper in the box containing the VCU118.
See Vivado [UG973](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug973-vivado-release-notes-install-license.pdf)
for download and installation instructions.

The GFE only requires the Vivado tool, not the SDK, so download the
`Vivado Design Suite - HLx 2019.1 ` from the
[Vivado Download Page](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2019-1.html).
You must make an account with Vivado in order to register the tool and
install the license.  After installing Vivado, you must also install
`libtinfo5` for Debian to run the tool.  Install this dependency by
running `sudo apt-get install libtinfo5`.

If you've already installed FTDI cable drivers and udev rules with a
previous version of Vivado or Vivado Lab, they should still work with
the new version.  If necessary, they can be (re)installed from the new
version:
```bash
cd /opt/Xilinx/Vivado_Lab/2019.1/data/xicom/cable_drivers/lin64/install_script/install_drivers/
sudo ./install_drivers
cd -
```

If using separate development and testing machines, only the
development machine needs a license in order to build new bitstreams.
We recommend installing Vivado Lab on the testing machine because it
does not require a license and is solely used to program the FPGA.

### Clone this Repo ###

Once the OS is installed, you will need to
[add an ssh key](https://gitlab-ext.galois.com/profile/keys)
to your Galois GitLab account in order to clone the GFE repo.
These [instructions](https://docs.gitlab.com/ee/ssh/#adding-an-ssh-key-to-your-gitlab-account)
have more details.

After setting up an ssh key, clone this repo by running
```bash
git clone git@gitlab-ext.galois.com:ssith/gfe.git
cd gfe
```

### Update Dependencies ###

The GFE relies on several nested Git submodules to provide processor
sources and RISC-V development tools.

Because some of these submodules contain redundant copies of the
toolchain, we provide a script to initialize only those necessary for
GFE development.
```bash
./init_submodules.sh
```

As of Release 4.2, **Nix is no longer required** to run GFE software.
The Nix shell from release 3 of the tool-suite project can still be
used if desired, but tool-suite is no longer a submodule of GFE.  The
`deps.sh` script below will install necessary system packages using
`apt`.

The `build-openocd.sh` script will build a GFE-specific development
version of `riscv-openocd` from the included submodule, placing an
executable in `/usr/local/bin/openocd`.

The `download-toolchains.sh` script downloads a 1.1GB archive
containing pre-built copies of both the newlib
(`riscv64-unknown-elf-*`) and Linux (`riscv64-unknown-linux-gnu-*`)
variants of the GNU toolchain, which should be unpacked into
`/opt/riscv` after backing up any files which may already exist there.
The archive is served from Google Drive. If you cannot access it, try
downloading the file from Galois' OwnCloud service, using [this
link](https://owncloud-tng.galois.com/index.php/s/WFVC0TnUgc7Efos) in
your browser, and saving the archive in the install directory.

The scripts should be run directly from the root of this repo:
```bash
sudo ./install/deps.sh
sudo ./install/build-openocd.sh
(cd install; sudo ./download-toolchains.sh)
# WARNING: tar will overwrite any existing /opt/riscv/ tree!
sudo tar -C / -xf install/riscv-gnu-toolchains.tar.gz
```

The `riscv32-unknown-elf-*` tools are not included in this `/opt/riscv`
tree, as they are now redundant. The tools labeled `64` all work with
32-bit binaries, although they may require explicit flags (such as
`-march=rv32gc` for gcc) to get the behaviors that were implicit
defaults of the corresponding `32` versions.

Finally, make the GNU toolchains and Vivado Lab 2019.1 available to
all users by running this script:
```bash
sudo ./install/amend-bashrc.sh
```

You may want to verify that the new version of the `vivado_lab`
program is available in your normal user shell:
```bash
vivado_lab -version
```

### Configure Network

Your GFE host PC should reserve one ethernet interface to connect
directly to the ethernet adapter onboard the VCU118, with static IP
address `10.88.88.1/24`. This is required by the Linux and FreeRTOS
networking tests.  Detailed [setup instructions](install/network.md)
are included in the install directory.

### Building the Bitstream ###

To build your own bitstream, make sure Vivado 2019.1 is on your path
(`$ which vivado`) and run the following commands:
```bash
cd $GFE_REPO
./setup_soc_project.sh chisel_p1 # generate vivado/soc_chisel_p1/soc_chisel_p1.xpr
./build.sh chisel_p1 # generate bitstreams/soc_chisel_p1.bit
```
where `GFE_REPO` is the top level directory for the GFE repository.
If you pass the filename of a binary image as an optional second 
parameter to `setup_soc_project.sh`, the boot ROM for the SoC will be 
configured to securely boot that binary image. See the 
[secure boot instructions](bootrom-secure/README.md) for more information.

To view the project in the Vivado GUI, run the following:
```bash
cd $GFE_REPO/vivado
vivado soc_chisel_p1/soc_chisel_p1.xpr
```

`setup_soc_project.sh` should only be run once. We also recommend
running `build.sh` for the initial build then performing future builds
using the Vivado GUI to take advantage of convenient error reporting
and visibility into the build process. The Vivado project will be
generated in the `$GFE_REPO/vivado/soc_$proc_name` folder of the
repository and can be re-opened there. Note that all the same commands
can be run with the argument `bluespec_p1` to generate the Bluespec P1
bitstream and corresponding Vivado project
(i.e., `./setup_soc_project.sh bluespec_p1`).

Note: when you build a SoC project, whether with `build.sh` or the
Vivado GUI, it will take the boot ROM from the `bootrom-configured`
directory. This allows you to modify the boot ROM after project
configuration (by, for example, manually changing the checksum and
length of the binary image a secure boot ROM should boot). However, it
also means that you must be careful when building a SoC project, if you
have run `setup_soc_project.sh` multiple times, to ensure that it builds 
with the boot ROM you expect. 

All bitstreams generated using processor names of the form
`{bluespec,chisel}_p{1,2,3}` build a system with SVF but no PCIe root
complex.

Release 5.1 adds two new bitstreams - `chisel_p2_pcie.bit` and
`bluespec_p2_pcie.bit`. These are FPGA systems with a PCIe root complex
and no SVF. For example, run the following to build `chisel_p2_pcie.bit`:
```bash cd $GFE_REPO
./setup_soc_project.sh chisel_p2_pcie # generate vivado/soc_chisel_p1/soc_chisel_p2_pcie.xpr
vivado/soc_chisel_p2_pcie/soc_chisel_p2_pcie.xpr ./build.sh chisel_p2_pcie # generate bitstreams/soc_chisel_p2_pcie.bit
```

Vivado run complexity is significantly reduced by eliminating builds
instantiating both a PCIe root complex and a PCIe endpoint. There is no loss
in capability since the SVF flow control reduces the RISC-V instruction
bandwidth to a level where the PCIe root firmware can't run.

This PCIe root complex build option is not provided for P1, which doesn't
support Linux, or for P3 whose frequency is too low to support PCIe
root complex operation).

### Storing a Bitstream in Flash Memory ###

See [flash-scripts/README](flash-scripts/README) for directions on how
to write a bitstream to flash on the VCU118.  This is optional, and
allows the FPGA to be programmed from flash on power-up.

As of the GFE 5.0 release, the ability to store bitstreams in flash
is not functional. See #141 for updates on the re-introduction of this
feature.

### Testing ###

We include some automated tests for the GFE.  The
`pytest_processor.py` script programs the FPGA with an appropriate
bitstream, tests the GDB connection to the FPGA then runs the
appropriate ISA and operating system tests.  To check that you have
properly setup the GFE, or to test a version you have modified
yourself, run the following steps:
1. Give the current user access to the serial and JTAG devices.
```bash
sudo usermod -aG dialout $USER
sudo usermod -aG plugdev $USER
sudo reboot
```
2. Connect micro USB cables to JTAG and UART on the the VCU118. This
   enables programming, debugging, and UART communication.
3. Make sure the VCU118 is powered on (fan should be running)
4. Add Vivado or Vivado Lab to your path
   (i.e. `source /opt/Xilinx/Vivado_Lab/2019.1/settings64.sh`).
5. Run `./pytest_processor.sh chisel_p1` from the top level of the GFE
   repo. Replace `chisel_p1` with your processor of choice. This
   command will program the FPGA and run the appropriate tests for
   that processor.

A passing test will not display any error messages. All failing tests
will report errors and stop early.

## Simulation ##

For Verilator simulation instructions, see
[verilator_simulators/README](verilator_simulators/).  To build and
run ISA tests on a simulated GFE processor, run, e.g.,
```bash
./pytest_processor.py bluespec_p1 --sim
```

## Manually Running FreeRTOS ##

To run FreeRTOS on the GFE, you'll need to run OpenOCD, connect to
GDB, and view the UART output in Minicom. First, install Minicom and
build the FreeRTOS demo.

```bash
sudo apt-get install minicom

cd FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1

# for simple blinky demo
make clean; PROG=main_blinky make

# for full demo
make clean; PROG=main_full make
```

We expect to see warnings about memory alignment and timer demo
functions when compiling.

Follow these steps to run FreeRTOS with an interactive GDB session:
1. Reset the SoC by pressing the CPU_RESET button (SW5) on the VCU118
   before running FreeRTOS.
2. Run OpenOCD to connect to the RISC-V core you have running on the
   FPGA:
   `openocd -f $GFE_REPO/testing/targets/ssith_gfe.cfg`.
   Note: openocd will fail if it cannot connect over JTAG, e.g. if
   Vivado programmer is still active.
3. In a new terminal, run Minicom with
   `minicom -D /dev/ttyUSB1 -b 115200`.
   `ttyUSB1` should be replaced with whichever USB port is connected
   to the VCU118's USB-to-UART bridge.

   Settings can be configured by running `minicom -s` and selecting
   `Serial Port Setup` and then `Bps/Par/Bits`.  The UART is
   configured to have 8 data bits, 2 stop bits, no parity bits, and a
   baud rate of 115200.

3. In a new shell, run GDB with `riscv64-unknown-elf-gdb -x bootmem/startup.gdb $GFE_REPO/FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1/main_blinky.elf`, where `main_blinky` should be the name of the demo you have compiled and want to run. The startup gdb script resets the SoC and connects gdb to OpenOCD. 

4. To run, type `c` or `continue`.

The expected output from simple blinky test is:
```
[0]: Hello from RX
[0]: Hello from TX
[1] TX: awoken
[1] RX: received value
Blink !!!
[1]: Hello from RX
[1] TX: sent
[1]: Hello from TX
[2] TX: awoken
[2] RX: received value
Blink !!!
[2]: Hello from RX
[2] TX: sent
[2]: Hello from TX
[3] TX: awoken
[3] RX: received value
Blink !!!
...
```

The expected output from full test is:
```
Starting main_full
Pass....
```

If you see error messages, then something went wrong.

To run any `.elf` file on the GFE, you can use `./pytest_processor.py $cpu --elf $elffile --timeout $val` where `$cpu` is the processor bitstream you want to use, and `$val` is the duration in seconds for how long the program is run after loading. You can skip loading the bitfile using `--no-bitstream` argument. If you are waiting for a specific output from the program, you can use `--expected $contents` argument - this will lead to an early exit once the `$contents$` are received (useful for example for running benchmarks we are not sure how long they run).
in `$GFE_REPO/testing/scripts/`. It can be run using `python
run_elf.py path_to_elf/file.elf`. By default the program waits 0.5
seconds before printing what it has received from UART, but this can
be changed by using the `--runtime X` argument where X is the number
of seconds to wait.

### Running FreeRTOS + TCP/IP stack ###

Details about the FreeRTOS TCP/IP stack can be found
[here](https://www.freertos.org/FreeRTOS-Plus/FreeRTOS_Plus_TCP/index.html).
We provide a small example, demonstrating the ICMP (ping), UDP, and
TCP functionality.

Our setup is below:
```
----------------------------------                       ---------------------------------------
|    HOST COMPUTER               |                       |      FPGA Board                     |
|    Static IP                   |    Ethernet cable     |      Static IP                      |
|    IP: 10.88.88.1              |<=====================>|      IP: 10.88.88.2                 |
|    Netmask: 255.255.255.0      |                       |      MAC: 00:0A:35:04:DB:77         |
----------------------------------                       ---------------------------------------
```

If you want to replicate our setup you should:
1) On your host machine, set up a static IP for the network interface
   connecting to the FPGA
2) If you have only one FPGA on the network, then you can leave the
   MAC address as is, otherwise
   [change it](https://github.com/GaloisInc/FreeRTOS-mirror/blob/p1_release/FreeRTOS/Demo/RISC-V_Galois_P1/FreeRTOSIPConfig.h#L325)
   to the MAC address of the particular board (there is a sticker on
   the FPGA board next to the Ethernet adapter).
3) If you change the host IP, reflect the changes accordingly in
   [FreeRTOSIPConfig](https://github.com/GaloisInc/FreeRTOS-mirror/blob/p1_release/FreeRTOS/Demo/RISC-V_Galois_P1/FreeRTOSIPConfig.h#L315)

Follow the steps below:
1) Program your FPGA with a P1 bitstream:
   `./pyprogram_fpga.sh chisel_p1`
   **NOTE:** If you have already programmed the FPGA, at least restart
   it before continuing to make sure it is in a good state.
2) Start openocd with `openocd -f $GFE_REPO/testing/targets/ssith_gfe.cfg`
3) Connect the FPGA Ethernet port with the host ethernet port
4) Go to the demo directory: `cd FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1`
5) Generate `main_tcp.elf` binary: `export PROG=main_tcp; make clean; make`
6) Start GDB: `riscv64-unknown-elf-gdb main_tcp.elf`
7) in your GDB session type: `target remote localhost:3333`
8) in your GDB session type: `load`
9) start Minicom: `minicom -D /dev/ttyUSB1 -b 115200`
10) in your GDB session type: `continue`
11) In Minicom, you will see a bunch of debug prints. The interesting
   piece is when you get:
```
IP Address: 10.88.88.2
Subnet Mask: 255.255.255.0
Gateway Address: 10.88.88.1
DNS Server Address: 10.88.88.1
```
   which means the FreeRTOS has the network interface up and is ready to
   communicate.
12) Open a new terminal, and type `ping 10.88.88.2` (or whatever is
   the FPGA's IP address) - you should see something like this:
```
$ ping 10.88.88.2
PING 10.88.88.2 (10.88.88.2) 56(84) bytes of data.
64 bytes from 10.88.88.2: icmp_seq=1 ttl=64 time=14.1 ms
64 bytes from 10.88.88.2: icmp_seq=2 ttl=64 time=9.22 ms
64 bytes from 10.88.88.2: icmp_seq=3 ttl=64 time=8.85 ms
64 bytes from 10.88.88.2: icmp_seq=4 ttl=64 time=8.84 ms
64 bytes from 10.88.88.2: icmp_seq=5 ttl=64 time=8.85 ms
64 bytes from 10.88.88.2: icmp_seq=6 ttl=64 time=8.83 ms
64 bytes from 10.88.88.2: icmp_seq=7 ttl=64 time=8.83 ms
^C
--- 10.88.88.2 ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6007ms
rtt min/avg/max/mdev = 8.838/9.663/14.183/1.851 ms
```
That means ping is working and your FPGA is responding.

13) Now open another terminal and run TCP Echo server at port 9999:
  `ncat -l 9999 --keep-open --exec "/bin/cat" -v`
  Note that this will work only if your TCP Echo server is at
  10.88.88.1 (or you
  [updated the config file](https://github.com/GaloisInc/FreeRTOS-mirror/blob/p1_release/FreeRTOS/Demo/RISC-V_Galois_P1/FreeRTOSIPConfig.h#L315)).
  After a few seconds, you will see something like this:
```
$ ncat -l 9999 --keep-open --exec "/bin/cat" -v
Ncat: Version 7.60 ( https://nmap.org/ncat )
Ncat: Generating a temporary 1024-bit RSA key. Use --ssl-key and --ssl-cert to use a permanent one.
Ncat: SHA-1 fingerprint: 2EDF 34C4 1F16 FF89 0AE1 6B1B F236 D933 A4DD 030E
Ncat: Listening on :::9999
Ncat: Listening on 0.0.0.0:9999
Ncat: Connection from 10.88.88.2.
Ncat: Connection from 10.88.88.2:25816.
Ncat: Connection from 10.88.88.2.
Ncat: Connection from 10.88.88.2:2334.
Ncat: Connection from 10.88.88.2.
Ncat: Connection from 10.88.88.2:14588.
```

14) [Optional] start `wireshark` and inspect the interface that is at
  the same network as the FPGA. You should clearly see the ICMP ping
  requests and responses, as well as the TCP packets to and from the
  echo server.  16) [Optional] Send a UDP packet with
  `socat stdio udp4-connect:10.88.88.2:5006 <<< "Hello there"`.
  In the Minicom output, you should see `prvSimpleZeroCopyServerTask:
  received $N bytes` depending on how much data you send. **Hint:**
  instead of Minicom, you can use `cat /dev/ttyUSB1 > log.txt` to
  redirect the serial output into a log file for later inspection.

**Troubleshooting**

If something doesn't work, then:
1) check that your connection is correct (e.g., if you have a DHCP
  server, it is enabled in the FreeRTOS config, or that your static IP
  is correct)
2) sometimes restarting the FPGA with `CPU_RESET` button (or typing
  `reset` in GDB) will help
3) Check out our
  [Issue](https://gitlab-ext.galois.com/ssith/gfe/issues) - maybe you
  have a problem we already know about.

## Running Linux - Debian or Busybox ##

### Creating Debian Image ###

Before starting, there are several necessary packages to install. Run:
```
apt-get install libssl-dev debian-ports-archive-keyring binfmt-support qemu-user-static mmdebstrap
```

The debian directory includes several scripts for creating a Debian
image and a simple Makefile to run them. Running `make debian` from
`$GFE_REPO/bootmem` will perform all the steps of creating the
image. If you want to make modifications to the chroot and then build
the image, you can do the following:
``` bash
# Using the scripts
cd $GFE_REPO/debian

# Create chroot and compress cpio archive
sudo ./create_chroot.sh

# Enter chroot
sudo chroot riscv64-chroot/

# ... Make modifications to the chroot ...

# Remove apt-cache and list files to decrease image size if desired
./clean_chroot

# Exit chroot
exit

# Recreate the cpio.gz image
sudo ./create_cpio.sh

# Build kernel and bbl
cd $GFE_REPO/bootmem
make debian
```
To decrease the size of the image, some language man pages,
documentation, and locale files are removed.  This results in warnings
about locale settings and man files that are expected.

If you want to install more packages than what is included, run `sudo
./create_chroot.sh package1 package2` and substitute `package1` and
`package2` with all the packages you want to install. Then recreate
the `cpio.gz` image and run `make debian` as described above. If
installing or removing packages manually rather than with the script,
use `apt-get` to install or remove any packages from within the chroot
and run `./clean_chroot` from within the chroot afterwards.

The bbl image is located at `$GFE_REPO/bootmem/build-bbl/bbl` and can
be loaded and run using GDB. The default root password is `riscv`.

A memory image is also created that can be loaded into the flash ROM
on the FPGA at `$GFE_REPO/bootmem/bootmem.bin`

### Creating Busybox Image ###

The following instructions describe how to boot Linux with Busybox.

#### Build the Memory Image ####

The default make target will build a simpler kernel with only a
busybox boot environment:
```bash
cd $GFE_REPO/bootmem/
make
```

#### Load and Run the Memory Image ####

Follow these steps to run Linux and Busybox with an interactive GDB
session:
1. Reset the SoC by pressing the CPU_RESET button (SW5) on the VCU118
   before running Linux.
2. Run OpenOCD to connect to the riscv core `openocd -f
   $GFE_REPO/testing/targets/ssith_gfe.cfg`.
3. In a new terminal, run Minicom with
   `minicom -D /dev/ttyUSB1 -b 115200`. `ttyUSB1`
   should be replaced with whichever USB port is connected to the
   VCU118's USB-to-UART bridge. Settings can be configured by running
   `minicom -s` and selecting `Serial Port Setup` and then
   `Bps/Par/Bits`.

   The UART is configured to have 8 data bits, 2 stop bits, no parity
   bits, and a baud rate of 115200. In the Minicom settings, make sure
   hardware flow control is turned off. Otherwise, the Linux terminal
   may not be responsive.
4. In a new terminal, run GDB with
   `riscv64-unknown-elf-gdb $GFE_REPO/bootmem/build-bbl/bbl`.
5. Once GDB is open, type `target remote localhost:3333` to connect to
   OpenOCD. OpenOCD should give a message that it has accepted a GDB
   connection.
6. On Bluespec processors, run `continue` then interrupt the processor
   with `Ctrl-C`. The Bluespec processors start in a halted state, and
   need to run the first few bootrom instructions to setup `a0` and
   `a1` before booting Linux. See #40 for more details.
7. Load the Linux image onto the processor with `load`. To run, type
   `c` or `continue`.
8. When you've finished running Linux, make sure to reset the SoC
   before running other tests or programs.

   In the serial terminal you should expect to see Linux boot
   messages.  The final message says ```Please press Enter to activate
   this console.```.  If you do as instructed (press enter), you will
   be presented with a shell running on the GFE system.

### Using Ethernet on Linux ###

The GFE-configured Linux kernel includes the Xilinx AXI Ethernet
driver. You should see the following messages in the boot log:
```
[    4.320000] xilinx_axienet 62100000.ethernet: assigned reserved memory node ethernet@62100000
[    4.330000] xilinx_axienet 62100000.ethernet: TX_CSUM 2
[    4.330000] xilinx_axienet 62100000.ethernet: RX_CSUM 2
[    4.340000] xilinx_axienet 62100000.ethernet: enabling VCU118-specific quirk fixes
[    4.350000] libphy: Xilinx Axi Ethernet MDIO: probed
```
The provided configuration of busybox includes some basic networking
utilities (ifconfig, udhcpc, ping, telnet, telnetd) to get you
started. Additional utilities can be compiled into busybox or loaded
into the filesystem image (add them to `$GFE_REPO/bootmem/_rootfs/`).

***Note*** Due to a bug when statically linking glibc into busybox,
DNS resolution does not work. This will be fixed in a future GFE
release either in busybox or by switching to a full Linux distro.

***Note*** There is currently a bug in the Chisel P3 that may result
in a kernel panic when using the provided Ethernet driver. A fix will
be released shortly.

The Debian image provided has the iproute2 package already installed
and is ready for many network environments.

**DHCP IP Example**

On Debian, the `eth0` interface can be configured using the
`/etc/network/interfaces` file followed by restarting the network
service using `systemctl`.

On busybox, you must manually run the DHCP client:
```
/ # ifconfig eth0 up
...
xilinx_axienet 62100000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
...
/ # udhcpc -i eth0
udhcpc: started, v1.30.1
Setting IP address 0.0.0.0 on eth0
udhcpc: sending discover
udhcpc: sending select for 10.0.0.11
udhcpc: lease of 10.0.0.11 obtained, lease time 259200
Setting IP address 10.0.0.11 on eth0
Deleting routers
route: SIOCDELRT: No such process
Adding router 10.0.0.2
Recreating /etc/resolv.conf
 Adding DNS server 10.0.0.2
```

On either OS, you can run `ping 4.2.2.1` to test network connectivity. The expected output of this is:
```
PING 4.2.2.1 (4.2.2.1): 56 data bytes
64 bytes from 4.2.2.1: seq=0 ttl=57 time=22.107 ms
64 bytes from 4.2.2.1: seq=1 ttl=57 time=20.754 ms
64 bytes from 4.2.2.1: seq=2 ttl=57 time=20.908 ms
64 bytes from 4.2.2.1: seq=3 ttl=57 time=20.778 ms
^C
--- 4.2.2.1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 20.754/21.136/22.107 ms
/ #
```

**Static IP Example**

Use the commands below to enable networking when a DHCP server is not
available. Replace the IP and router addresses as necessary for your
setup:
 - On busybox:
```
/ # ifconfig eth0 10.0.0.3
/ # route add 10.0.0.0/24 dev eth0
/ # route add default gw 10.0.0.1
```
 - On Debian:
```
/ # ip addr add 10.0.0.3 dev eth0
/ # ip route add 10.0.0.0/24 dev eth0
/ # ip route add default via 10.0.0.1
/ # ping 4.2.2.1
PING 4.2.2.1 (4.2.2.1): 56 data bytes
64 bytes from 4.2.2.1: seq=0 ttl=57 time=23.320 ms
64 bytes from 4.2.2.1: seq=1 ttl=57 time=20.738 ms
...
^C
--- 4.2.2.1 ping statistics ---
20 packets transmitted, 20 packets received, 0% packet loss
round-trip min/avg/max = 20.536/20.913/23.320 ms

/ #
```

### Storing a Boot Image in Flash Memory ###

1. Prepare the Linux image with either Debian or Busybox as described
   above.
2. Write to flash memory on the board with the command
   `tcl/program_flash datafile bootmem/bootmem.bin`. Note that this
   command is run from the shell (not inside vivado).
3. The `program_flash` command overwrites the FPGA's
   configuration. Depending on your setup, follow the relevant
   instructions below:
    * If a suitable P2 or P3 bitstream is also stored in flash, the
      board can be physically reset or cold rebooted to automatically
      boot into Linux.
    * Otherwise, you will have to reprogram the desired bit file using
      the `program_fpga.sh` script at this point. The processor will
      execute the flash image immediately.

Occasionally, the `tcl/program_flash` command will end with an out of
memory error. As long as `Program/Verify Operation successful.` was
printed before existing, the flash operation was completed.

There will not be any console messages while the boot image is read
from flash, which could take some time for the full Debian OS.

Note that if there is a binary image in flash that is incompatible with
the bitstream programmed onto the FPGA (for example, a 64-bit boot image
with a P1 SoC, or a binary image with invalid instructions), the processor
may not work properly. In particular, OpenOCD may fail to run. To avoid
such issues, always erase flash with `tcl/erase_flash` when you are done
working with a boot image stored in flash.

## Adding in Your Processor ##

We recommend using the Vivado IP integrator flow to add a new
processor into the GFE. This should require minimal effort to
integrate the processor and this flow is already demonstrated for the
Chisel and Bluespec processors. Using the integrator flow requires
wrapping the processor in a Xilinx User IP block and updating the
necessary IP search paths to find the new IP. The Chisel and Bluespec
Vivado projects are created by sourcing the same tcl for the block
diagram (`soc_bd.tcl`). The only difference is the location from which
it pulls in the ssith_processor IP block.

The steps to add in a new processor are as follows:
1. Duplicate the top level Verilog file `mkCore_P1.v` from the Chisel
   or Bluespec designs and modify it to instantiate the new
   processor. See
   `$GFE_REPO/chisel_processors/P1/xilinx_ip/hdl/mkP1_Core.v` and
   `$GFE_REPO/bluespec-processors/P1/Piccolo/src_SSITH_P1/xilinx_ip/hdl/mkP1_Core.v`
   for examples.
2. Copy the component.xml file from one of the two processors and
   modify it to include all the paths to the RTL files for your
   design. See
   `$GFE_REPO/bluespec-processors/P1/Piccolo/src_SSITH_P1/xilinx_ip/component.xml`
   and `$GFE_REPO/chisel_processors/P1/xilinx_ip/component.xml`. This
   is the most clunky part of the process, but is relatively straight
   forward.
    *  Copy a reference component.xml file to a new folder (i.e.,
       `cp $GFE_REPO/chisel_processors/P1/xilinx_ip/component.xml new_processor/`)
    *  Replace references to old Verilog files within
       component.xml. Replace `spirit:file` entries such as
    ```xml
    <spirit:file>
        <spirit:name>hdl/galois.system.P1FPGAConfig.behav_srams.v</spirit:name>
        <spirit:fileType>verilogSource</spirit:fileType>
    </spirit:file>
    ```
   with paths to the hdl for the new processor such as:
    ```xml
    <spirit:file>
        <spirit:name>hdl/new_processor.v</spirit:name>
        <spirit:fileType>verilogSource</spirit:fileType>
    </spirit:file>
    ```
    The paths in component.xml are relative to its parent directory
    (i.e., `$GFE_REPO/chisel_processors/P1/xilinx_ip/`).
    * Note that the component.xml file contains a set of files used
      for simulation
      (xilinx_anylanguagebehavioralsimulation_view_fileset) and
      another set used for synthesis. Make sure to replace or remove
      file entries as necessary in each of these sections.
    * Vivado discovers user IP by searching all it's IP repository
      paths looking for component.xml files. This is the reason for
      the specific name. This file fully describes the new processor's
      IP block and can be modified through a GUI if desired using the
      IP packager flow. It is easier to start with an example
      component.xml file to ensure the port naming and external
      interfaces match those used by the block diagram.

3. Add your processor to `$GFE_REPO/tcl/proc_mapping.tcl`. Add a line
   here to include the mapping between your processor name and
   directory containing the component.xml file. This mapping is used
   by the `soc.tcl` build script.
    ```bash
    vim tcl/proc_mapping.tcl
    # Add line if component.xml lives at ../new_processor/component.xml
    + dict set proc_mapping new_processor "../new_processor"
    ```
   The mapping path is relative to the `$GFE_REPO/tcl` path
4. Create a new Vivado project with your new processor by running the
   following:
    ```bash
    cd $GFE_REPO
    ./setup_soc_project.sh new_processor
    ```
   new_processor is the name specified in the
   `$GFE_REPO/tcl/proc_mapping.tcl` file.

5. Synthesize and build the design using the normal flow. Note that
   users will have to update the User IP as prompted in the GUI after
   each modification to the component.xml file or reference Verilog
   files.

All that is required (and therefore tracked by git) to create a Xilinx
User IP block is a component.xml file and the corresponding Verilog
source files.  If using the Vivado GUI IP packager, the additional
project collateral does not need to be tracked by git.

### Modifying the GFE ###

To save changes to the block diagram in git (everything outside the
SSITH Processor IP block), please open the block diagram in Vivado and
run `write_bd_tcl -force ../tcl/soc_bd.tcl`. Additionally, update
`tcl/soc.tcl` to add any project settings.

### Rebuilding the Chisel and Bluespec Processors ###

The compiled Verilog from the latest Chisel and Bluespec build is
stored in git to enable building the FPGA bitstream right away. To
rebuild the Bluespec processor, follow the directions in
`bluespec-processors/P1/Piccolo/README.md`. To rebuild the Chisel
processor for the GFE, run the following commands
```bash
cd chisel_processors/P1
./build.sh
```

## Tandem Verification ##

Below are instructions for setting up Tandem verification on the GFE. For
more information on the trace collected by Tandem Verification see
[trace-protocol.pdf](trace-protocol.pdf).

### Establishing the PCIe Link ###

Begin by compiling the provided version of the `bluenoc` executable and
kernel module:
```bash
$ # Install Kernel Headers
$ sudo apt-get install linux-headers-$(uname -r)
$ cd bluenoc/drivers
$ make
$ sudo make install
$ cd ../bluenoc
$ make
```

Next, program the FPGA with a tandem-verification enabled bitstream:
`./pyprogram_fpga.py bluespec_p2`

**Note: This process is motherboard-dependent.**

If using the prescribed MSI motherboard in your host machine, you will
need to power the VCU118 externally using the supplied power
brick. You must be able to fully shut down the computer while
maintaining power to the FPGA. Turn off your host machine and then
turn it back on.

On computers with Asus motherboards (and potentially others), a warm
reboot may be all that is necessary.

After the cold or warm reboot, run the `bluenoc` utility to determine if
the PCIe link has been established:
```bash
$ cd bluenoc/bluenoc
$ ./bluenoc
Found BlueNoC device at /dev/bluenoc_1
  Board number:     1
  Board:            Xilinx VCU118 (A118)
  BlueNoC revision: 1.0
  Build number:     34908
  Timestamp:        Wed Dec 21 13:41:31 2016
  SceMi Clock:      41.67 MHz
  Network width:    4 bytes per beat
  Content ID:       5ce000600080000
  Debug level:      OFF
  Profiling:        OFF
  PCIe Link:        ENABLED
  BlueNoC Link:     ENABLED
  BlueNoC I/F:      READY
  Memory Sub-Sys:   ENABLED
```

After the link has been established, you may reprogram the FPGA with
other TV-enabled bitstreams and re-establish the PCIe link with just a
warm reboot.  If you program a bitstream that does not include the
tandem verification hardware, you may need to follow the cold reboot
procedure to re-establish the link later on.

For some but not all motherboards, once the link has beeen established, it
might be possible to reprogram the FPGA with another TV-enabled bitstream and
re-establish the link without a warm reboot. After reprogramming, the commands
```
cd bluenoc/bluenoc
./bluenoc_hotswap
```
might be all that is necessary.

### Capturing asd Verifying Traces ###

Information about these activities may be found in the separate document
TV-README.md.

## PCI Express Root Complex ##

### PCIe-Enabled Bitstreams

Two bistreams are provided - `chisel_p2_pcie.bit` and `bluespec_p2_pcie.bit`
Note that the PCIe bitstreams can be run only with a full PCIe hardware setup (FMC Card + PCIe peripheral, or FMC Card + PCIe expansion set), having only
the FMC card is not enough.


### PCIe Hardware Setup ###

To utilize the PCIe root port, the following hardware setup is required:
- Install the FMC card (HiTech Global HTG-FMC-PCIE) into J22 on the
  VCU118.  This is the FMC connector on the left, when viewing the
  VCU118 with the PCIe edge connector pointing downward, as shown below:
  ![FMC jumper configuration][fmc_jumper]
- Install a jumper between JP3 and JP4 on the PCIe FMC card.
- Set switch S2 to the position labeled FMC (away from the FMC
  connector) as shown below:
  ![FMC card configuration][fmc_card_config]
- Connect the USB controller card into J1 on HTG-FMC-PCIE (the edge
  connector on the FMC card):
  ![PCIe root complex with USB PCIe card][pcie_usb]
- Alternatively, connect the Ethernet card into J1 on HTG-FMC-PCIE (the edge
  connector on the FMC card):
  ![PCIe root complex with Ethernet PCIe card][pcie_ethernet]
- Alternatively, a PCIe expansion chassis may be connected to the FMC
  card by way of expansion cards and cable.

### PCIe Reset ###

Every time a bitfile is loaded, prior to loading the bitfile, the PCIe
bus must be reset by pressing S1 on HTG-FMC-PCIE (the RESET PCIE
button on the FMC card).

### PCIe Testing ###

#### Ethernet ####

* If you are testing the ethernet card, you have to first bring the
  interface up
* Then you have to assign it a static IP address (busybox currently
  doesn't support DHCP)

#### USB ####

* We tested the USB card with a genetic USB keyboard, USB mouse and a
  USB memory stick.
* If you plug in a keyboard or a mice, and want to see if it works,
  type `dd if=/dev/input/event0 | od` in the busybox terminal, and you
  should see numbers rolling on the screen as you press keys/move the
  mouse.  The numbers are decoded events coming from the devices.

[fmc_jumper]: documentation_source/images/FMC_JUMPER.JPG "FMC jumper connection"
[fmc_card_config]: documentation_source/images/FMC_CARD_CONFIG.JPG "FMC card configuration"
[pcie_ethernet]: documentation_source/images/PCIE_ROOT_COMPLEX_ETHERNET.JPG "PCIe root complex with Ethernet PCIe card"
[pcie_usb]: documentation_source/images/PCIE_ROOT_COMPLEX_USB.JPG "PCIe root complex with USB PCIe card"

## Baseline Performance

### PPA

Run the `./get_ppa.py` script to get numbers measured by Vivado, for
example:
```
$ ./get_ppa.py vivado/soc_bluespec_p1/soc_bluespec_p1.runs/impl_1/
{"power_W": 0.25, "CLB_LUTs": 90341, "CLB_regs": 118324, "cpu_Mhz": 50.0}
```

Baseline values as of GFE 4.x release:

| processor | power_W | CLB_LUTs | CLB_regs | cpu_Mhz |
|------|---|---|---|---|
| Bluespec P1 | 0.25 | 90341 | 118324 | 50.0 |
| Bluespec P2 | 0.302 | 121254 | 128260 | 100.0 |
| Bluespec P3 | 0.365 | 343698 | 250477 | 25.0 |
| Chisel P1 | 0.267 | 84043 | 113347 | 50.0 |
| Chisel P2 | 0.457 | 131524 | 188846 | 100.0 |
| Chisel P3 | 0.37 | 188629 | 156332 | 25.0 |


## LLVM and Clang for RISC-V

Support for the RISC-V architecture in LLVM and Clang graduated to "stable" in
upstream releases as of LLVM 9.0 (Sep'19). You are recommended to use upstream
LLVM and Clang unless directed otherwise (e.g. to temporarily use a downstream
branch that includes additional yet-to-be-upstreamed fixes). As such, the
[LLVM getting started
documentation](https://llvm.org/docs/GettingStarted.html) is a good source on
how to checkout and build the project.

If developing your own patches for LLVM, you should develop those either on
top of the most recent release branch or on the `master` branch and regularly
rebase or merge in changes (the trade-offs between the two approaches have
been discussed extensively within the LLVM community). If simply using
Clang/LLVM, building and using the 10.0 release branch is recommended:

    git clone https://github.com/llvm/llvm-project.git
    cd llvm-project
    git checkout release/10.x
    mkdir -p build && cd build
    cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DLLVM_TARGETS_TO_BUILD="all" \
      -DLLVM_APPEND_VC_REV=False ../../llvm
    cmake --build .

LLVM binaries will be produced in the `build/bin` directory.

When building software with Clang, as with GCC, you are advised to pass
explicit `-march` and `-mabi` arguments to specify the RISC-V ISA string and
target ABI. In addition to these, you should pass:
* `--target=...` to specify the target triple. e.g. `riscv64-unknown-linux-gnu`
  (for 64-bit Linux targets) or `riscv32-unknown-elf` (for 32-bit bare metal).
* `--gcc-toolchain=...` to specify the location of a built RISC-V GCC
  toolchain. Clang uses this to identify the location of the GNU linker and
  compiler support libraries like libgcc. Avoiding this dependnecy, using LLD
  and compiler-rt can be done and is being used successfully in the FreeBSD
  community, but has not yet seen the same degree of testing as this approach.
* `--sysroot=...` to specify the location of the sysroot containing headers,
  libraries, etc for the target.
