{ pkgs }:

pkgs.writeShellScriptBin "update-kubeconfig" ''
  # This script is used to update the kubeconfig file with the credentials for the rewstCluster in a given AWS profile.
  #  We do this so that we can use our SSO credentials to administer the cluster with kubectl.

  function usage() {
      echo "Usage: $0 --profile=<PROFILE_NAME>"
      echo "  PROFILE_NAME: The name of the AWS profile to use. Use the same names that you use in the ~/.aws/config file."
      echo "  NOTE: Make sure you run aws configure sso --profile=<PROFILE_NAME> before running this script."
      exit 1
  }

  if [[ "$1" != --profile=* ]]; then
      echo "Error: --profile flag is required."
      usage
  fi

  # Extract profile value from the flag
  PROFILE=''\${1#*=}

  # Check AWS identity
  if ! aws sts get-caller-identity --profile="$PROFILE" >/dev/null 2>&1; then
      echo "Error: Failed to get AWS caller identity. Please run:"
      echo "aws configure sso --profile=$PROFILE"
      exit 1
  fi


  echo "Fetching the name of the rewstCluster..."
  CLUSTER_NAME=$(aws eks list-clusters --profile="$PROFILE" --query="clusters[?contains(@, 'RewstK8sCluster')]" --output text)
  if [[ -z "$CLUSTER_NAME" ]]; then
      echo "Error: Could not find a cluster with the name 'rewstCluster' using profile $PROFILE."
      exit 1
  fi
  echo "Found cluster: $CLUSTER_NAME"

  echo "Fetching the ARN of the admin role..."
  ROLE_ARN=$(aws iam list-roles --profile="$PROFILE" --query="Roles[?contains(Arn, 'rewstEksAdmin')].Arn | [0]" --output text)
  if [[ -z "$ROLE_ARN" ]]; then
      echo "Error: Could not find a role ARN containing 'rewstEksAdmin' using profile $PROFILE."
      exit 1
  fi
  echo "Found role ARN: $ROLE_ARN"

  echo "Updating kubeconfig..."
  # shellcheck disable=SC2086
  if aws eks update-kubeconfig --profile="$PROFILE" --name="$CLUSTER_NAME" --alias="$PROFILE" --role-arn="$ROLE_ARN"; then
      echo "Kubeconfig updated successfully!"
  else
      echo "Error: Failed to update kubeconfig."
      exit 1
  fi
''
