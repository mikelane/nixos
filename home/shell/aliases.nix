{
  programs.zsh.shellAliases = {
    aws-connect-qa = "awsvpnclient start --config $HOME/workplace/rewst-qa-vpn-client-config.ovpn";
    cat = "bat";
    dcd = "docker compose -f $HOME/workplace/rewst-app/packages/engine/tests/.dev/docker-compose.yml down";
    dcu = "docker compose -f $HOME/workplace/rewst-app/packages/engine/tests/.dev/docker-compose.yml up -d";
    nix-lint = ''find . -name "*.nix" ! -name "hardware-configuration.nix" -exec nixpkgs-fmt {} +'';
    k = "kubectl";
    ls = "eza --icons --long --group-directories-first --classify --git --all --extended";
    mk = "minikube";
    reta = "(cd $HOME/workplace/rewst-app/packages/engine; DATABASE_HOST=localhost DATABASE_PORT=15432 KAFKA_BROKER=127.0.0.1:19092 pytest -ra -n 24 -vv)";
    retax = "(cd $HOME/workplace/rewst-app/packages/engine; DATABASE_HOST=localhost DATABASE_PORT=15432 KAFKA_BROKER=127.0.0.1:19092 pytest -ra -n 24 -x -vv)";
    rets = "(cd $HOME/workplace/rewst-app/packages/engine; DATABASE_HOST=localhost DATABASE_PORT=15432 KAFKA_BROKER=127.0.0.1:19092 pytest -ra -vv)";
    update = "sudo nixos-rebuild switch --flake $HOME/nixos/ && exec zsh";
    update_system = "(cd $HOME/nixos && sudo nix flake update && update)";
  };
}
