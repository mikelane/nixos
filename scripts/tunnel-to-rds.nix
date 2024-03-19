{ pkgs }:

let
  rdsHosts = builtins.toJSON {
    "rewst-prod-us" = {
      port = 15432;
      rw = "prod-writer.c9xkwgfwwjv3.us-east-2.rds.amazonaws.com";
      ro = "prod-reader-1.c9xkwgfwwjv3.us-east-2.rds.amazonaws.com";
    };
    "rewst-prod-eu" = {
      port = 25432;
      rw = "rewststack-rewstprodeuprimarydbc86fc3d0-kkfzeltzahl1.cmrguqafnvis.eu-west-2.rds.amazonaws.com";
      ro = "rewststack-rewstprodeureadreplica1b5425e04-czrs1cpcdhnw.cmrguqafnvis.eu-west-2.rds.amazonaws.com";
    };
    "rewst-qa" = {
      port = 35432;
      rw = "qa-master.c9xkwgfwwjv3.us-east-2.rds.amazonaws.com";
      ro = "qa-reader.c9xkwgfwwjv3.us-east-2.rds.amazonaws.com";
    };
    "rewst-staging" = {
      port = 45432;
      rw = "rewststack-rewststagingprimarydb1ecb19e7-gah7ijumbzrd.czox7dqbun8h.us-east-2.rds.amazonaws.com";
      ro = "rewststack-rewststagingreadreplica13ad24a57-zt5as6wkix39.czox7dqbun8h.us-east-2.rds.amazonaws.com";
    };
    "rewst-dev" = {
      port = 55432;
      rw = "rewststack-rewstdevprimarydbffe78611-9ogb6aadyxfs.ccnfbt5hqiqg.us-east-2.rds.amazonaws.com";
      ro = "rewststack-rewstdevreadreplica15fe794d9-wgrgyxp6jacd.ccnfbt5hqiqg.us-east-2.rds.amazonaws.com";
    };
  };
in
pkgs.writeShellApplication {
  name = "tunnel-to-rds";
  runtimeInputs = with pkgs; [ jq ];
  text = ''
    RDS_HOSTS_JSON='${rdsHosts}'

    if ! krew list | grep -q 'relay'; then
      echo "Error: kubectl relay plugin is not installed. Please install the relay plugin to use this script."
      exit 1
    fi

    # Cull any inactive pid temp files
    for pid_file in /tmp/tunnel-to-rds-*.pid; do
      if [ -f "$pid_file" ]; then
          pid=$(cat "$pid_file")

          if ! ps -p "$pid" -o comm= | grep -q "kubectl-relay"; then
              rm -f "$pid_file"
          fi
      fi
    done

    # Function to display help message
    show_help() {
      echo "Usage: tunnel-to-rds [options]"
      echo ""
      echo "Options:"
      echo "  --env [context][:rw]      Establish a tunnel to the specified kubectl context. Append ':rw' for read/write access; defaults to read-only."
      echo "                            This flag can be passed multiple times to establish tunnels to multiple environments simultaneously."
      echo "  --stop                    Stop all running tunnels."
      echo "  --show                    Display all currently active tunnels."
      echo "  --help                    Display this help message."
      echo ""
      echo "Examples:"
      echo "  tunnel-to-rds --env rewst-prod-us                             Connect to the US production environment using a read-only connection."
      echo "  tunnel-to-rds --env rewst-prod-eu:rw                          Connect to the EU production environment using a read/write connection."
      echo "  tunnel-to-rds --env rewst-prod-us --env rewst-qa              Connect to both the US production and QA environments using read-only connections."
      echo "  tunnel-to-rds --env rewst-prod-us --env rewst-prod-eu:rw      Connect to the US production environment in read-only mode and the EU production environment in read/write mode."
      echo "  tunnel-to-rds --stop                                          Stop all established tunnels."
      echo "  tunnel-to-rds --show                                          Show all active tunnels."
    }

    # Function to show all active tunnels
    show_tunnels() {
      echo "Active tunnels:"
      for pid_file in /tmp/tunnel-to-rds-*.pid; do
      if [ -f "$pid_file" ]; then
        local context_mode
        local mode
        local context
        local pid

        context_mode=$(basename "$pid_file" .pid | sed 's/tunnel-to-rds-//')
        mode=''$(echo "$context_mode" | grep -o -E '(ro|rw)$')
        mode=''${mode//ro/read-only}
        mode=''${mode//rw/read-write}
        context="''${context_mode%-*}"
        pid="$(cat "$pid_file")"
        echo "- $context ($mode), PID: $pid"
      fi
      done
    }

    start_tunnel() {
      local full_env
      local mode
      local context
      local rw_mode
      local db_host
      local port
      local pid_file
      local existing_mode

      full_env=$1
      mode=''${2:-ro} # Default mode is read-only if not specified
      context=''${full_env%:*}
      rw_mode=''${full_env##*:}

      if [ "$rw_mode" = "rw" ]; then
        mode="rw"
      fi

      db_host=$(echo "$RDS_HOSTS_JSON" | jq -r --arg context "$context" --arg mode "$mode" '.[$context][$mode]')
      port=$(echo "$RDS_HOSTS_JSON" | jq -r --arg context "$context" '.[$context].port')

      if [[ "$db_host" == "null" || "$port" == "null" ]]; then
        echo "Error: Configuration for context '$context' with mode '$mode' not found or incomplete."
        return 1
      fi

      if ! is-logged-into-sso "$context"; then
        echo "Not logged into SSO for $context. Logging you in now..."
        sso "$context"
        # Optional: Check if the login was successful before proceeding
      fi

      pid_file="/tmp/tunnel-to-rds-$context-$mode.pid"
      existing_mode=""

      # Determine if there's an existing tunnel for this context (regardless of mode)
      if [ -f "$pid_file" ]; then
        existing_mode="$mode"
      elif [ -f "/tmp/tunnel-to-rds-$context-ro.pid" ]; then
        existing_mode="ro"
        pid_file="/tmp/tunnel-to-rds-$context-ro.pid"
      elif [ -f "/tmp/tunnel-to-rds-$context-rw.pid" ]; then
        existing_mode="rw"
        pid_file="/tmp/tunnel-to-rds-$context-rw.pid"
      fi

      if [ -n "$existing_mode" ]; then
        local pid
        pid="$(cat "$pid_file")"
        # Check if the existing tunnel's process is running
        if ps -p "$pid" > /dev/null 2>&1; then
          if [ "$existing_mode" != "$mode" ]; then
            echo "Switching from $existing_mode to $mode mode for $context."
            kill "$pid" && rm -f "$pid_file"
          else
            echo "A tunnel to $context ($mode) is already active with PID: $pid."
            return 0
          fi
        else
          # Process not running, cleanup PID file
          rm -f "$pid_file"
        fi
      fi

      # Proceed to establish a new tunnel if no active tunnel or after stopping the existing one in a different mode
      kubectl-relay --context="$context" host/"$db_host" "$port":5432 > "/tmp/kubectl-relay-$context-$mode.log" 2>&1 &
      echo $! > "/tmp/tunnel-to-rds-$context-$mode.pid"
    }

    stop_tunnels() {
      for pid_file in /tmp/tunnel-to-rds-*.pid; do
        if [ -f "$pid_file" ]; then
        kill "$(cat "$pid_file")" && rm -f "$pid_file"
        fi
      done
    }

    if [ $# -eq 0 ]; then
      show_help
      exit 1
    fi

    while [[ "$#" -gt 0 ]]; do
      case $1 in
        --env)
          env="$2"
          shift
          start_tunnel "$env"
          ;;
        --env=*)
          env="''${1#*=}"
          start_tunnel "$env"
          ;;
        --stop)
          stop_tunnels
          ;;
        --show)
          show_tunnels
          exit 0
          ;;
        --help)
          show_help
          exit 0
          ;;
       *)
          echo "Unknown or unsupported parameter: $1"
          show_help
          exit 1
          ;;
      esac
      shift
    done
  '';
}
