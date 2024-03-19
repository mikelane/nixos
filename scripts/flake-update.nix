{ pkgs }:

pkgs.writeShellScriptBin "flake-update" ''
  sudo nix flake update -I ~/nixos
  echo "Update complete. Running nixos-rebuild switch"
  update
''
