{ pkgs }:

pkgs.writeShellApplication {
  name = "ktx";
  runtimeInputs = with pkgs; [ kubectl ];
  text = ''
    ktx() {
      local ctx
      current_context=$(kubectl config current-context)
      ctx=$(kubectl config get-contexts -o name | grep -v "$current_context" | sort | sed "1 i\\$current_context" | fzf --height=~100% --reverse)
      [[ -n "$ctx" ]] && kubectl config use-context "$ctx"
    }

    ktx
  '';
}
