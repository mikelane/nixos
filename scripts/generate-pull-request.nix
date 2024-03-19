{ pkgs }:

let
  instructions = "Please use the included diff and the included pull request template to generate a pull request title and body as mardown text.";
in
pkgs.writeShellApplication {
  name = "generate-pull-request-body";
  runtimeInputs = with pkgs; [ shell_gpt ];
  text = ''
    get_ticket_number() {
        git rev-parse --abbrev-ref HEAD | grep -o 'sc-\([0-9]\+\)' | grep -o '[0-9]\+'
    }

    ticketNumber="$(get_ticket_number)"

    prBodyTemplate="
      # SC-''${ticketNumber}: <Title here>

      ## Overview

      <Insert a clear and concise overview here>

      ## Testing Instructions

      <Insert a clear and concise set of testing instructions here>

      ## Additional Changes

      <Insert any changes that aren't primary here>
      "

    check_commands_available() {
        local missing_cmds
        missing_cmds=()
        local cmds
        cmds=("sgpt" "pandoc") # Add any other required commands to this array

        for cmd in "''${cmds[@]}"; do
            if ! command -v "$cmd" &> /dev/null; then
                missing_cmds+=("$cmd")
            fi
        done

        if [ ''${#missing_cmds[@]} -ne 0 ]; then
            echo "Error: The following required commands are not installed or not in the PATH:"
            for cmd in "''${missing_cmds[@]}"; do
                echo "- $cmd"
            done
            exit 1
        fi
    }

    generate_pull_request() {
        check_commands_available

        local diff_output_file
        diff_output_file="diff_output.txt"
        local diff_lock_snap_file
        diff_lock_snap_file="diff_lock_snap.txt"

        # Generate the diff files
        git diff master -- . ':(exclude)**/*lock.yaml' ':(exclude)**/*.lock' ':(exclude)**/*.snap' ':(exclude)**/__generated__/*' > "$diff_output_file"
        git diff master --name-only -- . '**/*lock.yaml' '**/*.lock' '**/*.snap' '**/__generated__/*' > "$diff_lock_snap_file"

        echo "$prBodyTemplate" | cat - "$diff_output_file" "$diff_lock_snap_file" | sgpt "${instructions}"
        rm "$diff_output_file" "$diff_lock_snap_file"
    }

    generate_pull_request
  '';
}
