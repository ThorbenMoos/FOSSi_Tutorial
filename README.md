# FOSSi Tutorial
This is a tutorial.

## Part I - Compiling the First Chip Design
To get started you first need to perform a short environment setup. On Ubuntu Server 26.04 LTS the following commands have been tested for installing these utilities:

```
sudo apt update
sudo apt install -y git
sudo apt install -y curl
curl --proto '=https' --tlsv1.2 -fsSL https://artifacts.nixos.org/nix-installer | sh -s -- install --no-confirm --extra-conf "
    extra-substituters = https://nix-cache.fossi-foundation.org
    extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=
    extra-experimental-features = nix-command flakes
"
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
git clone https://github.com/ThorbenMoos/FOSSi_Tutorial
cd FOSSi_Tutorial
```

## RTL Design
The RTL design is fully written in VHDL, all sources are located in the ```src``` folder.

## Reading Material on Trivium
- The Trivium stream cipher [1] has been suggested for efficient concurrent pseudo-randomness generation in hardware masking schemes in [2].  

[1]: https://doi.org/10.1007/11836810_13  
[2]: https://doi.org/10.62056/akdkp2fgx, https://github.com/uclcrypto/randomness_for_hardware_masking  