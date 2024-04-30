{ pkgs }:

pkgs.writeShellApplication {
  name = "is-logged-into-sso";
  # runtimeInputs = with pkgs; [ awscli2 ];
  text = ''
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <profile>"
        exit 1
    fi

    profile="$1"

    aws sts get-caller-identity --profile="$profile" > /dev/null 2>&1
    exit $?
  '';
}
