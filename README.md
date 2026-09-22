# FOSSi Tutorial
This is a tutorial on the open silicon back-end based on GlobalFoundries' open-source [GF180MCU](https://gf180mcu-pdk.readthedocs.io/en/latest) PDK, the [wafer.space](https://wafer.space) [project template](https://github.com/wafer-space/gf180mcu-project-template), and the [LibreLane](https://librelane.readthedocs.io/en/latest) open-source EDA tool. It implements the [Trivium](https://doi.org/10.1007/11836810_13) stream cipher which is also a popular choice for efficient concurrent [pseudo-randomness generation in hardware masking schemes](https://doi.org/10.62056/akdkp2fgx).

## Step I - Nix/LibreLane Installation
To get started we first need to install LibreLane. It is provided as a [nix-based reproducible build](https://librelane.readthedocs.io/en/stable/installation/nix_installation/installation_linux.html) cached by the [FOSSi foundation](https://fossi-foundation.org) and can be installed using the following commands:

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

Navigate to the `Trivium_Chip_Macro/macros/trivium_4` directory:

```
cd Trivium_Chip_Macro/macros/trivium_4
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

On a machine with 8GB RAM and 2 Cores, this should take about 8 minutes. If everything goes well, the tool should report all Antenna, LVS and DRC checks as "Passed".