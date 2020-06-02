#!/bin/bash
#
# Set global environment variables based on the hosting config file

# Usage:
# bash set-envs.sh -e test -a web

set -e

# DEFAULT VALUES
#
# The config file location
CONFIG_FILE="../hosting.config.json"


# Parse the script parameters
while [[ $# -gt 0 ]]
do
  key="$1"

  # -e|--env: Environment to configure for
  case $key in
    -e|--env)
    ENV="$2"
    shift # past argument
    shift # past value
    ;;
  esac
done



# Verify config file exists
if [ -d "$CONFIG_FILE" ]; then
    echo "Can't find $CONFIG_FILE. Please create it."
    exit 1
fi

# parse_env () {
#     local envconfig="$1"
#     local env="$2"
#     local APPS=$(jq -r '.apps' <<< "$envconfig")
#     # echo $APPS
    
#     for app in $(jq -c 'to_entries | map_values(.value + { name: .key })[]' <<< "$APPS")
#     do
#         echo $env
#         echo $app
#         local app_name=$(jq -r '.name' <<< "$app")
#         oc process -f appuio_${app_name}.yml --local=true --param-file=./envs/${env}/${app_name}/env > ./envs/${env}/${app_name}/${app_name}.yml
#     done
# }

PROJECT_APPS=$(jq \
  --arg env "${ENV}" \
  '.environments[$env].apps' \
  $CONFIG_FILE)

APPUIO_PROJECT=$(jq -r \
  --arg env "${ENV}" \
  '.environments[$env].appuio_project' \
  $CONFIG_FILE)

for app in $(jq -c 'to_entries | map_values(.value + { name: .key })[]' <<< "$PROJECT_APPS")
do
    app_name=$(jq -r '.name' <<< "$app")
    # parse_env $env $ENV_NAME
    echo "Setting up $app_name on $APPUIO_PROJECT"
    filename="./envs/${ENV}/${app_name}/${app_name}.yml"
    # echo $(cat $filename)
    oc apply -f ./envs/${ENV}/${app_name}/${app_name}.yml -n $APPUIO_PROJECT
done



# echo $PROJECT_APPS

set +e