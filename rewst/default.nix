{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    (callPackage ./scripts/dump-qa-db.nix { })
    (callPackage ./scripts/update-kubeconfig.nix { })

    awscli2
    inputs.awsvpnclient.packages.x86_64-linux.awsvpnclient
    eksctl
    envsubst
    helmfile
    k9s
    kubectl
    (wrapHelm kubernetes-helm { plugins = [ kubernetes-helmPlugins.helm-diff ]; })
    minikube
    pgcli
    postgresql_14
  ];
}
