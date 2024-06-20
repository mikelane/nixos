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

            env = {
              NODE_PATH = "${pkgs.nodejs_20}/bin";
            };

            packages = [
              pkgs.nodejs_20
              pkgs.nodePackages.pnpm
            ];

            enterShell = ''
              echo
              echo "======================================================================================="
              echo "  Using node from ${pkgs.nodejs_20}"
              echo "  Using pnpm from ${pkgs.nodePackages.pnpm}"
              echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH" 
              echo "======================================================================================="
              echo 
            '';
          })
        ];
      };
    };
}

