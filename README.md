# FOSSi Tutorial
This is a tutorial on the open silicon back-end based on GlobalFoundries' open-source [GF180MCU](https://gf180mcu-pdk.readthedocs.io/en/latest) PDK, the [wafer.space](https://wafer.space) [project template](https://github.com/wafer-space/gf180mcu-project-template), and the [LibreLane](https://librelane.readthedocs.io/en/latest) open-source EDA tool. It implements the [Trivium](https://doi.org/10.1007/11836810_13) stream cipher which is also a popular choice for efficient concurrent [pseudo-randomness generation in hardware masking schemes](https://doi.org/10.62056/akdkp2fgx).

## Step I - LibreLane Installation
To get started we need to install LibreLane. It is provided as a [nix-based reproducible build](https://librelane.readthedocs.io/en/stable/installation/nix_installation/installation_linux.html) cached by the [FOSSi foundation](https://fossi-foundation.org) and can be installed using the following commands:

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

## Step II - Cloning this Repository

```
sudo apt install -y git
git clone https://github.com/ThorbenMoos/FOSSi_Tutorial
```

## Step II - Executing the RTL -> GDSII Flow to Build a Hard Macro

git clone https://github.com/ThorbenMoos/FOSSi_Tutorial
cd FOSSi_Tutorial


Antenna, LVS and DRC should be reported as "Passed".