{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # As of today, 2023-10-10, the python package oscrypto has a bug. When it loads `libcrypto.so` or `libssl.so` it runs a regex validator
    #  for the version string of openssl (which provides those files). In the current version of oscrypto, openssl 3.0.9 passes the
    #  validation; however, openssl 3.0.10 does not since 10 has 2 digits and 9 has one digit. :eyeroll: Vendoring and building oscrypto
    #  and importing it manually is more work than just going in and using openssl 3.0.9. So that's why we're going through these motions
    #  to import openssl 3.0.9.
    nixpkgs-openssl309.url = "github:NixOS/nixpkgs/7a031b95ea18a60c903fbee0897743a0e3297a89";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, nixpkgs-openssl309, ... } @ inputs:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      openssl-pkg = nixpkgs-openssl309.legacyPackages."x86_64-linux";
    in
    {
      devShell.x86_64-linux = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ({ pkgs, ... }: {
            # This is your devenv configuration
            env = {
              # We have to inform python where to find libcrypto.so, libssl.so, and libstdc++.so.6 because nixos puts these binary files into a
              #  dynamically generated location in `/nix/store`. 
              LD_LIBRARY_PATH = "${openssl-pkg.lib.makeLibraryPath [ openssl-pkg.openssl ]}:${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}";
              TEST_YARN_BIN = "${pkgs.yarn}/libexec/yarn/bin/yarn.js";  # :poop: but it works...
            };

            dotenv.enable = true;

            packages = [
              openssl-pkg.openssl
              pkgs.python311Full
              (pkgs.poetry.withPlugins (ps: with ps; [ poetry-plugin-up ]))
              pkgs.nodejs_18
              pkgs.yarn
            ];

            enterShell = ''
              echo
              echo "===================================================================================================================================================="
              echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
              echo "  TEST_YARN_BIN: $TEST_YARN_BIN"
              echo "===================================================================================================================================================="
              echo 
            '';
          })
        ];
      };
    };
}

