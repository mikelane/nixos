{
  description = "Mike's NixOS Flake";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # This is the standard format for flake.nix.
  # `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to
  # the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs.
    # The most widely used is `github:owner/name/reference`,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos-unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    awsvpnclient.url = "github:they4kman/aws-vpn-client-flake";
    agenix.url = "github:ryantm/agenix";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix.url = "github:helix-editor/helix/23.05";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
  };

  # `outputs` are all the build result of the flake.
  #
  # A flake can have many use cases and different types of outputs.
  # 
  # parameters in function `outputs` are defined in `inputs` and
  # can be referenced by their names. However, `self` is an exception,
  # this special parameter points to the `outputs` itself(self-reference)
  # 
  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, flake-utils, awsvpnclient, alacritty-theme, agenix, ... }:
    let
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        pkgs-stable = nixpkgs-stable.legacyPackages."x86_64-linux";
    in
  {

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      # By default, NixOS will try to refer the nixosConfiguration with
      # its hostname, so the system named `nixos-test` will use this one.
      # However, the configuration name can also be specified using:
      #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
      #
      # The `nixpkgs.lib.nixosSystem` function is used to build this
      # configuration, the following attribute set is its parameter.
      #
      # Run the following command in the flake's directory to
      # deploy this configuration on any NixOS system:
      #   sudo nixos-rebuild switch --flake .#nixos-test

      system = "x86_64-linux";

      # The Nix module system can modularize configuration,
      # improving the maintainability of configuration.
      #
      # Each parameter in the `modules` is a Nix Module, and
      # there is a partial introduction to it in the nixpkgs manual:
      #    <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
      # It is said to be partial because the documentation is not
      # complete, only some simple introductions.
      # such is the current state of Nix documentation...
      #
      # A Nix Module can be an attribute set, or a function that
      # returns an attribute set. By default, if a Nix Module is a
      # function, this function have the following default parameters:
      #
      #  lib:     the nixpkgs function library, which provides many
      #             useful functions for operating Nix expressions:
      #             https://nixos.org/manual/nixpkgs/stable/#id-1.4
      #  config:  all config options of the current flake, every useful
      #  options: all options defined in all NixOS Modules
      #             in the current flake
      #  pkgs:   a collection of all packages defined in nixpkgs,
      #            plus a set of functions related to packaging.
      #            you can assume its default value is
      #            `nixpkgs.legacyPackages."${system}"` for now.
      #            can be customed by `nixpkgs.pkgs` option
      #  modulesPath: the default path of nixpkgs's modules folder,
      #               used to import some extra modules from nixpkgs.
      #               this parameter is rarely used,
      #               you can ignore it for now.
      #
      # The default parameters mentioned above are automatically generated by Nixpkgs.
      # However, if you need to pass other non-default parameters to the submodules,
      # you'll have to manually configure these parameters using `specialArgs`.
      # you must use `specialArgs` by uncomment the following line:
      #
      # specialArgs = inputs; # pass custom arguments into all sub module.

      modules = [
        # Import the configuration.nix here, so that the
        # old configuration file can still take effect.
        # Note: configuration.nix itself is also a Nix Module,
        ./hosts/desktop/configuration.nix
        agenix.nixosModules.default

        ({ pkgs, ... }: {
          nixpkgs.overlays = [ inputs.alacritty-theme.overlays.default ];
        })
        home-manager.nixosModules.home-manager
        ({ pkgs, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.mikelane = import ./home/mikelane;
          home-manager.extraSpecialArgs = { inherit inputs pkgs-stable; };
        })
        ({ config, pkgs, ... }: {
          environment.systemPackages = [
            pkgs.home-manager
            agenix.packages.x86_64-linux.default
            (pkgs.callPackage ./scripts/update.nix { })
            (pkgs.callPackage ./scripts/flake-update.nix { })
            (pkgs.callPackage ./scripts/cecho.nix { })
            (pkgs.callPackage ./scripts/kubectl-change-context.nix { })
            (pkgs.callPackage ./scripts/generate-commit-message.nix { })
            (pkgs.callPackage ./scripts/generate-pull-request.nix { })
            (pkgs.callPackage ./scripts/tunnel-to-rds.nix { })
            (pkgs.callPackage ./scripts/sso.nix { })
            (pkgs.callPackage ./scripts/getktxs.nix { })
            (pkgs.callPackage ./scripts/sshpod.nix { })
          ];
        })
      ];
    };

    homeConfigurations = {
      mikelane = home-manager.lib.homeManagerConfiguration {
        imports = [
          ./home/mikelane/default.nix
        ];
        system = "x86_64-linux";
        homeDirectory = "/home/mikelane";
        username = "mikelane";
        configuration = { pkgs, ... }: { };
      };
    };
  };
}
