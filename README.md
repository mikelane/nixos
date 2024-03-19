# NixOS Configurations

This repo contains my NixOS configurations for my personal and work machines. I
use [home-manager]() to manage my user environment and [nixos]() to manage my
system environment.

## Installation

### Prerequisites

- [NixOS](https://nixos.org/download.html)
- [git](https://git-scm.com/downloads)
- [gh](https://cli.github.com/manual/installation) (optional)

> **Note**
> This is not yet set up to work with systems that are not NixOS. 

Update the `configuration.nix` file that was generated during the NixOS installation process to include git and gh in 
the `environment.systemPackages` list. 

```nix
  environment.systemPackages = with pkgs; [
    gh
    git
];
```

Run `sudo nixos-rebuild switch` to install git and gh on your system. Then authenticate with the gh cli:

```shell
gh auth login
```

### Fork The Repo and Clone It Locally 

```shell
cd ~
gh repo fork mikelane/nixos --clone --default-branch-only
```

### Create and Populate the Host in the `nixos/hosts` Directory

> **Note**
> the host name is what you'll use to specify what configuration to use when running `nixos-rebuild`. For example, if
> you have a host named `workstation`, you would run `sudo nixos-rebuild switch --flake .#workstation` to build and 
> switch to that configuration.

In the `/hosts` directory, create a new directory for your host. Use the existing hosts as an example. Then copy over
the `configuration.nix` and `hardware-configuration.nix` files that were generated during the NixOS installation to the
hosts directory. 

```shell
cd hosts
mkdir -p my-host
cp /etc/nixos/configuration.nix my-host/
cp /etc/nixos/hardware-configuration.nix my-host/
``` 

### Create a new user in the `home` directory and populate it with your home-manager configuration



### Add the host entry to the `flake.nix` file

```nix
{
  description = "Main NixOS Flake";

  nixConfig = {
    # no changes here
  };

  inputs = {
    # no changes here
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, awsvpnclient, agenix, ... }: {
    nixosConfigurations = {
      # If you've only cloned the repo, it's probably best to keep the existing entries. Otherwise, you can replace them
      desktop = nixpkgs.lib.nixosSystem {
        # No changes here if you keep the existing entries
      };
      
      my-host = nixpkgs.lib.nixosSystem {  # desktop changed to my-host
        system = "x86_64-linux";

        specialArgs = inputs; # pass custom arguments into all sub module.

        modules = [
          ./hosts/my-host/configuration.nix  # path changed from ./hosts/desktop/configuration.nix

          agenix.nixosModules.default

          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ 
              (import ./jetbrains-toolbox/jetbrains-toolbox-overlay.nix)
            ];
          })

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.yourusername = import ./home;  # make sure to update your username here
              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    };
  };
}
```
