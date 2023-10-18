{ pkgs }:

pkgs.writeShellScriptBin "dump-qa-db" ''
  cleanup() {
    echo -e "\e[1;33mKilling the VPN process $QA_PID\e[0m"
    kill $QA_PID 2>/dev/null
  }
  trap cleanup EXIT

  echo -e "\e[1;34mConnecting to QA VPN in the background\e[0m"
  awsvpnclient start --config $HOME/workplace/rewst-qa-vpn-client-config.ovpn > /dev/null 2>&1 &
  QA_PID=$!

  echo -e "\e[1;34mSleeping for 15 seconds to ensure the VPN connection has started\e[0m"
  sleep 15

  echo -e "\e[1;34mDumping the database schema and data to local files\e[0m"

  if [[ -z "''\${QA_DB_PASSWORD}" ]]; then
    echo -ne "\e[1;32mPlease enter the QA database password (you can find it in the Rewst 1password vault): \e[0m"
    read -s QA_DB_PASSWORD
    echo
  fi

  export PGPASSWORD="''\${QA_DB_PASSWORD}"
  pg_dump --host db.qa.rewst --port 5432 --username rewst --dbname rewst --schema public --format custom --schema-only --file schema.dump --no-privileges --no-security-labels --no-tablespaces --verbose --exclude-table-data 'public.workflow_executions' --exclude-table-data 'public.task_logs' --exclude-table-data 'public.action_options' --exclude-table-data 'public.action_options' --exclude-table-data 'public.database_notifications'
  pg_dump --host db.qa.rewst --port 5432 --username rewst --dbname rewst --schema public --format custom --data-only --disable-triggers --file data.dump --no-privileges --no-security-labels --no-tablespaces --verbose --exclude-table-data 'public.workflow_executions' --exclude-table-data 'public.task_logs' --exclude-table-data 'public.action_options' --exclude-table-data 'public.action_options' --exclude-table-data 'public.database_notifications'

  echo -ne "\e[1;32mDo you want to dump the data into your local database?\e[0m "
  read -n 1 -r REPLY
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    # ensure minikube is running
    if ! minikube status >/dev/null 2>&1; then
      echo -e "\e[1;34mStarting minikube...\e[0m"
      minikube start
    fi

    echo -e "\e[1;34mRestoring the database from the files...\e[0m"
    SERVICE_IP=$(minikube ip)
    export PGPASSWORD=secretpassword
    pg_restore --host $SERVICE_IP --port 31514 --user postgres --dbname rewst --no-owner --no-privileges --no-security-labels --clean --if-exists --verbose schema.dump
    pg_restore --host $SERVICE_IP --port 31514 --user postgres --dbname rewst --no-owner --no-privileges --no-security-labels --clean --if-exists --disable-triggers --verbose data.dump
  fi
''

