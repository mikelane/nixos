{ pkgs }:

pkgs.writeShellApplication {
  name = "dump-qa-db";
  runtimeInputs = with pkgs; [ postgresql_16 ];
  text = ''
    AUTOMATIC="no"
    while getopts "y" opt; do
      case $opt in
        y) AUTOMATIC="yes";;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
      esac
    done

    if is-logged-into-sso rewst-qa; then
      cecho green "You are logged into rewst-qa."
    else
      cecho yellow "Not logged into SSO for rewst-qa. Logging you in now..."
      sso rewst-qa
    fi

    cecho blue "Starting the rewst-qa rds tunnel"
    tunnel-to-rds --env=rewst-qa

    cecho yellow "Waiting for 5 seconds to ensure the tunnel is established..."
    sleep 5

    cecho blue "Dumping the database schema and data to local files"

    pg_dump --dbname=service=rewst-qa --schema public --format custom --schema-only --file schema.dump --no-privileges --no-security-labels --no-tablespaces --verbose
    pg_dump --dbname=service=rewst-qa --schema public --format custom --data-only --disable-triggers --file data.dump --no-privileges --no-security-labels --no-tablespaces --verbose --exclude-table-data 'public.workflow_executions' --exclude-table-data 'public.task_logs' --exclude-table-data 'public.action_options' --exclude-table-data 'public.database_notifications' --exclude-table-data 'public.workflow_execution_contexts' --exclude-table-data 'public.task_execution_stats*' --exclude-table-data 'public.workflow_execution_stats*'

    if [[ $AUTOMATIC == "yes" ]] || { read -p "$(cecho green "Do you want to dump the data into your local database? (y/n) ")" -n 1 -r REPLY; echo; [[ $REPLY =~ ^[Yy]$ ]]; }; then
      if ! minikube status >/dev/null 2>&1; then
        cecho blue "Starting minikube..."
        minikube start
      fi

      cecho blue "Restoring the minikube database from the files..."
      pg_restore --dbname=service=minikube --no-owner --no-privileges --no-security-labels --clean --if-exists --verbose schema.dump
      pg_restore --dbname=service=minikube --no-owner --no-privileges --no-security-labels --clean --if-exists --disable-triggers --verbose data.dump
    fi
  '';
}
