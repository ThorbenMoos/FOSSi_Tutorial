# FOSSi Tutorial
This is a tutorial on the open silicon back-end based on GlobalFoundries' open-source [GF180MCU](https://gf180mcu-pdk.readthedocs.io/en/latest) PDK, the [wafer.space](https://wafer.space) [project template](https://github.com/wafer-space/gf180mcu-project-template), and the [LibreLane](https://librelane.readthedocs.io/en/latest) open-source EDA tool. It implements the [Trivium](https://doi.org/10.1007/11836810_13) stream cipher which is a popular choice for efficient concurrent [pseudo-randomness generation in hardware masking schemes](https://doi.org/10.62056/akdkp2fgx). All commands have been tested on Ubuntu 26.04.01 LTS.

## Step I - Nix/LibreLane Installation
To get started we first need to install LibreLane. It is provided as a [nix-based reproducible build](https://librelane.readthedocs.io/en/stable/installation/nix_installation/installation_linux.html) cached by the [FOSSi foundation](https://fossi-foundation.org) and can be installed using the following commands on Ubuntu:

```
sudo apt update
sudo apt install -y curl
curl --proto '=https' --tlsv1.2 -fsSL https://artifacts.nixos.org/nix-installer | sh -s -- install --no-confirm --extra-conf "
    extra-substituters = https://nix-cache.fossi-foundation.org
    extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=
    extra-experimental-features = nix-command flakes
"
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
```

## Step II - Cloning this Repository and Opening a Nix-Shell

To clone this repository and start a nix shell you may execute the following commands:

```
sudo apt install -y git
git clone https://github.com/ThorbenMoos/FOSSi_Tutorial
cd FOSSi_Tutorial
nix-shell
```

Within the nix-shell the librelane command is available in addition to a number of other useful utilities. Try running `librelane --help` and have a quick look at its usage (no need to read it all).

## Step III - Cloning the GF180MCU PDK

To clone the GF180MCU PDK, in particular its standard IO library and 7 track standard cell library, run the following command:

```
ciel enable f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7 --pdk-root gf180mcu --pdk-family gf180mcuD --include-libraries gf180mcu_fd_io --include-libraries gf180mcu_fd_sc_mcu7t5v0
```

## Step IV - Executing the RTL -> GDS-II Flow to Build a Hard Macro

Navigate to the `Trivium_Chip_Macro/macros/Trivium` directory:

```
cd Trivium_Chip_Macro/macros/Trivium
```

Take a look at the `Trivium.vhd` source file and try to understand how the module works. Note the "output_bits" generic (equivalent to a Verilog parameter) which determines how many keystream bits the module produces per clock cycle. A corresponding testbench for output_bits=4 is provided in the `Testbenches` subfolder. Then open the `Trivium.yaml` configuration file and have a look at the different parameters. In particular, try to understand the "CLOCK_PERIOD" and "FP_CORE_UTIL" parameters, if needed with the help of the [LibreLane documentation](https://librelane.readthedocs.io/en/latest). Since LibreLane does not support VHDL, we first need to quickly convert the RTL code into Verilog:

```
ghdl -a Trivium.vhd
ghdl synth Trivium > Trivium.v
```

Now we can perform the full automated librelane flow to produce a clean GDS-II file implementing the Trivium module:

```
librelane Trivium.yaml --pdk gf180mcuD --pdk-root gf180mcu --manual-pdk
```

On a machine with 8GB RAM and 2 Cores, this should take about 8 minutes. While waiting you may want to pay some attention to the different flow steps that are executed and check the contents of the generated `runs` folder that are appearing as the tool progresses. If everything goes well, the tool should report all Antenna, LVS and DRC checks as "Passed". Congratulations, you have produced a manufacturable chip design! You can have a look at it using [Klayout](https://github.com/klayout/klayout) by prompting:

```
klayout runs/RUN*/final/Trivium.gds
```

Now we can try to improve the macro's cost and performance by decreasing the "CLOCK_PERIOD" (e.g. to 10) and increasing the "FP_CORE_UTIL" (e.g. to 40) value in the `Trivium.yaml` configuration file. Then we can re-run the previous steps with the prepared Makefile by calling:

```
make all
```

While you are waiting, feel free to explore the `runs` folder to see the outputs of the different steps of the LibreLane flow. Once finished you can open the design in Klayout again and may notice that it has gotten smaller and more dense compared to before.

## Step V - Integrating the Hard Macro into a Chip

For this step we have integrated the Trivium design into a toplevel module that let's you provide the seed serially through a 4-bit bus. You may have a quick look at the `FOSSi_Tutorial/Trivium_Chip_Macro/src/Trivium_Chip.vhd` file. Then we have integrated the toplevel `Trivium_Chip` module into the [wafer.space project template](https://github.com/wafer-space/gf180mcu-project-template). You may have a look at `FOSSi_Tutorial/Trivium_Chip_Macro/chip_top.sv` and `FOSSi_Tutorial/Trivium_Chip_Macro/chip_top.yaml` to see how the IO pads, IO ring and hard macros are instantiated and placed. You may execute the entire flow with the prepared Makefile:

```
make all
```

On a machine with 8GB RAM and 2 Cores, this should take about 45 minutes, but you can see the intermediate results as they appear. The first GDS output should be ready a good 10 minutes before the finish. If everything goes well, the tool should report all Antenna and LVS checks as "Passed". Full DRC checks have not been performed for time reasons. They can be activated at the top of the `chip_top.yaml` file if you want to play around after the tutorial. Congratulations, you have produced a manufacturable chip design that can be submitted to a foundry for fabrication! You can open it in Klayout and have a look. You can rerun this step after the tutorial with a different placement of the hard macro to see how the optics of the GDS file change.

## Step VI - Full Design in a Single run

As an alternative to the previous flow of first pre-hardening a macro and then integrating it into a chip frame, you can also do everything in one go. For this, you may navigate to the `FOSSi_Tutorial/Trivium_Chip` folder and once again use the prepared Makefile:

```
make all
```

On a machine with 8GB RAM and 2 Cores, this should take about 35 minutes. If everything goes well, the tool reports all Antenna and LVS checks as "Passed". Full DRC checks have once again not been performed for time reasons. Open the chip design in Klayout and see how different it looks from the macro-based design. What do you notice?

## Step VII - Advanced: Increase the Throughput of your Chip

If the previous tasks have been easy for you, you may now go ahead and increase the "output_bits" parameter in the `FOSSi_Tutorial/Trivium_Chip/src/Trivium_Chip.vhd` and adapt the `FOSSi_Tutorial/Trivium_Chip/chip_top.sv` and `FOSSi_Tutorial/Trivium_Chip/chip_top.yaml`files accordingly to instantiate sufficiently many IO cells for the larger output bus. There is plenty of space in the IO rind and on the chip. However, depending of your choice of output bits per cycle you may need to increase the clock period. Rerun the design and look at the result.
