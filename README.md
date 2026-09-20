# FOSSi Tutorial
This is a tutorial.

## Part I - Compiling the First Chip Design
To get started you first need to perform a short environment setup. In particular, you need to install [git](https://github.com/git/git), [ghdl](https://github.com/ghdl/ghdl), [iverilog (Icarus Verilog)](https://github.com/steveicarus/iverilog), the make utility, [curl](https://github.com/curl/curl) and the [nix](https://github.com/NixOS/nix) package manager. On Ubuntu Server 26.04 LTS the following commands have been tested for installing these utilities:

```
sudo apt update
sudo apt install -y git
sudo apt install -y ghdl
sudo apt install -y make
sudo apt install -y iverilog
sudo apt install -y curl
curl --proto '=https' --tlsv1.2 -fsSL https://artifacts.nixos.org/nix-installer | sh -s -- install --no-confirm --extra-conf "
    extra-substituters = https://nix-cache.fossi-foundation.org
    extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=
    extra-experimental-features = nix-command flakes
"
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Once these steps are completed, clone this repository (```git clone https://github.com/ThorbenMoos/FOSSi_Tutorial```) into a folder that is a convenient workspace for you, enter its directoy and call ```nix-shell```. Inside the shell simply call ```make all``` and wait for the result. The Makefile verifies testbenches, converts the sources, clones the PDK and executes the librelane flow. Finally, the [wafer.space precheck](https://github.com/wafer-space/gf180mcu-precheck) is executed to complete the sign-off procedure and confirm manufacturability. On a 16-core machine with 32 GB RAM, the overall runtime should be XX minutes, about XX min. for the initial flow and XX min. for the precheck. If everything goes well, the design should pass all testbenches as well as the Antenna, DRC and LVS checks, both in the initial flow and the precheck.

## RTL Design
The RTL design is fully written in VHDL, all sources are located in the ```src``` folder.

## Reading Material on Trivium
- The Trivium stream cipher [1] has been suggested for efficient concurrent pseudo-randomness generation in hardware masking schemes in [2].  

[1]: https://doi.org/10.1007/11836810_13  
[2]: https://doi.org/10.62056/akdkp2fgx, https://github.com/uclcrypto/randomness_for_hardware_masking  