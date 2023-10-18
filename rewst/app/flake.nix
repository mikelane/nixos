{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in
    {
      devShell.x86_64-linux = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ({ pkgs, ... }: {
            # This is your devenv configuration

            dotenv.enable = true;

            packages = [
              pkgs.nodejs_18
              pkgs.yarn
            ];

            enterShell = ''
              echo
              echo "======================================================================================="
              echo "  Using node from ${pkgs.nodejs_18}"
              echo "  Using yarn from ${pkgs.yarn}"
              echo "======================================================================================="
              echo
            '';
          })
        ];
      };
    };
}

