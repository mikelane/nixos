{
  programs.zsh.shellAliases = {
    vpn-prod-us = "([[ -f $HOME/workplace/rewst-prod-us.ovpn ]] || { echo 'VPN configuration file for rewst-prod-us does not exist.'; exit 1; }) && (aws sts get-caller-identity --profile=rewst-prod-us > /dev/null 2>&1 || sso rewst-prod-us) && tmux new-session -s awsvpn-us 'awsvpnclient serve --config /home/mikelane/workplace/rewst-prod-us.ovpn'";
    vpn-prod-eu = "([[ -f $HOME/workplace/rewst-prod-eu.ovpn ]] || { echo 'VPN configuration file for rewst-prod-eu does not exist.'; exit 1; }) && (aws sts get-caller-identity --profile=rewst-prod-eu > /dev/null 2>&1 || sso rewst-prod-eu) && tmux new-session -s awsvpn-eu 'awsvpnclient serve --config /home/mikelane/workplace/rewst-prod-eu.ovpn'";
    vpn-qa = "([[ -f $HOME/workplace/rewst-qa.ovpn ]] || { echo 'VPN configuration file for rewst-qa does not exist.'; exit 1; }) && (aws sts get-caller-identity --profile=rewst-qa > /dev/null 2>&1 || sso rewst-qa) && tmux new-session -s awsvpn-qa 'awsvpnclient serve --config /home/mikelane/workplace/rewst-qa.ovpn";
    vpn-dev = "([[ -f $HOME/workplace/rewst-dev.ovpn ]] || { echo 'VPN configuration file for rewst-dev does not exist.'; exit 1; }) && (aws sts get-caller-identity --profile=rewst-dev > /dev/null 2>&1 || sso rewst-dev) && tmux new-session -s awsvpn-dev 'awsvpnclient serve --config /home/mikelane/workplace/rewst-dev.ovpn'";
    src = "exec $SHELL";
    cat = "bat";
    dcd = "docker compose -f $HOME/workplace/rewst-app/packages/engine/tests/.dev/docker-compose.yml down";
    dcu = "docker compose -f $HOME/workplace/rewst-app/packages/engine/tests/.dev/docker-compose.yml up -d";
    dcps = "docker compose -f $HOME/workplace/rewst-app/packages/engine/tests/.dev/docker-compose.yml ps";
    nix-lint = ''find . -name "*.nix" ! -name "hardware-configuration.nix" -exec nixpkgs-fmt {} +'';
    k = "kubectl";
    ls = "eza --icons --long --group-directories-first --classify --git --all --extended";
    mk = "minikube";
    reta = "(cd $HOME/workplace/rewst-app/packages/engine; DATABASE_HOST=localhost DATABASE_PORT=15432 KAFKA_BROKER=127.0.0.1:19092 pytest -ra -n 24 -vv)";
    retax = "(cd $HOME/workplace/rewst-app/packages/engine; DATABASE_HOST=localhost DATABASE_PORT=15432 KAFKA_BROKER=127.0.0.1:19092 pytest -ra -n 24 -x -vv)";
    rets = "(cd $HOME/workplace/rewst-app/packages/engine; DATABASE_HOST=localhost DATABASE_PORT=15432 KAFKA_BROKER=127.0.0.1:19092 pytest -ra -vv)";
    ping = "prettyping";
  };
}
