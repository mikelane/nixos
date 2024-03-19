{ pkgs }:

pkgs.writeShellScriptBin "update" ''
  sudo nixos-rebuild switch --flake ~/nixos#$HOSTNAME
  echo "Update complete. Executing a new instance of the zsh shell..."
  exec zsh
''
