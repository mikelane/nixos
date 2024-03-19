{ pkgs }:

pkgs.writeShellApplication {
  name = "getktxs";
  runtimeInputs = with pkgs; [ kubectl ]; # Ensure kubectl is available in the script's PATH
  text = ''
    current_context=$(kubectl config current-context)
    context_names=$(kubectl config get-contexts --output=name | grep -v "$current_context")
    echo "$current_context"
    echo "$context_names"
  '';
}
