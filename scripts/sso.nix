{ pkgs }:

pkgs.writeShellScriptBin "sso" ''
  profile=''${1:-$(grep '\[profile ' ~/.aws/config | sed 's/\[profile //;s/\]//' | fzf --height=~100% --reverse)}
  aws sso login --profile "$profile"
''
