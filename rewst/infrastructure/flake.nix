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
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      devShell.x86_64-linux = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ({ pkgs, config, ... }: {
            # This is your devenv configuration
            env = {
                PTPYTHON_CONFIG_HOME = "/home/mikelane/.local/share/ptpython/";
            };

            dotenv.enable = true;

            packages = with pkgs; [
              poetry
              pre-commit
              python312Full
              isort
              ruff
              ruff-lsp
              yarn
            ];

            enterShell = ''
              echo
              echo "===================================================================================================================================================="
              echo "  Python Executable: $(which python)"
              echo "    Ruff Executable: $(which ruff)"
              echo "   iSort Executable: $(which isort)"
              echo "===================================================================================================================================================="
              echo
            '';
          })
        ];
      };
    };
}
