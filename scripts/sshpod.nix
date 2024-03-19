{ pkgs }:

pkgs.writeShellApplication {
  name = "sshpod";
  runtimeInputs = with pkgs; [ kubectl ];
  text = ''
    context=""
    app=""
    pod_name=""

    show_help() {
      echo "Usage: $0 [-c|--context <context>] [-a|--app <app>] [--help]"
      echo "SSH into a running pod in AWS EKS"
      echo ""
      echo "Options:"
      echo "  -c, --context <context>  Set the Kubernetes context (optional)"
      echo "  -a, --app <app>          Set the app name to identify the pod (optional)"
      echo "  --help                   Show this help message"
      exit 0
    }

    get_kubectl_context() {
      selected_context="$(getktxs | generate_selection_menu)"
      if [ -z "$selected_context" ]; then
        echo "Error: No Kubernetes context found in ~/.kube/config."
        exit 1
      fi
      echo "$selected_context"
    }

    get_pod_name() {
      pod_list=""
      cmd="kubectl --context=$1 get pods -n default"

      if [ -n "$app" ]; then
        cmd="$cmd --selector=app=$app --field-selector=status.phase=Running"
      fi

      pod_list="$($cmd --output=name | awk -F/ '{print $NF}')"

      if [ -z "$app" ]; then
        echo "$pod_list" | generate_selection_menu
        exit 0
      fi

      if [ -z "$pod_list" ]; then
        echo "Error: No running pod found for app '$app' in the default namespace for the selected context."
        exit 1
      fi

      echo "$pod_list" | head -n 1
    }

    generate_selection_menu() {
      fzf --height=~100% --reverse
    }

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -c|--context)
          context="$2"
          shift 2
          ;;
        -a|--app)
          app="$2"
          shift 2
          ;;
        --context=*)
          context="''${1#*=}"
          shift
          ;;
        --app=*)
          app="''${1#*=}"
          shift
          ;;
        --help)
          show_help
          ;;
        *)
          show_help
          ;;
      esac
    done

    if [ -z "$context" ]; then
      context="$(get_kubectl_context)"
    fi

    if [ -z "$pod_name" ]; then
      pod_name="$(get_pod_name "$context")"
    fi

    if [ -z "$context" ]; then
      echo "Error: No Kubernetes context provided or found in ~/.kube/config."
      exit 1
    fi

    if [ -z "$pod_name" ]; then
      echo "Error: No app name or pod selected. Please specify the app using '-a' or select a pod using '-c' and '-a'."
      exit 1
    fi

    if [[ "$app" == "engine" ]]; then
      shell="/bin/bash"
    elif [[ "$app" == "graph-api" ]]; then
      shell="/bin/sh"
    else
      # Default shell if app is neither engine nor graph-api
      shell="/bin/sh"
    fi

    echo "SSH into context: $context pod: $pod_name"
    kubectl --context="$context" exec -it "$pod_name" -- $shell
  '';
}
