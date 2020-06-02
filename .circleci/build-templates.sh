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

# Verify config file exists
if [ -d "$CONFIG_FILE" ]; then
    echo "Can't find $CONFIG_FILE. Please create it."
    exit 1
fi

parse_env () {
    local envconfig="$1"
    local env="$2"
    local APPS=$(jq -r '.apps' <<< "$envconfig")
    # echo $APPS
    
    for app in $(jq -c 'to_entries | map_values(.value + { name: .key })[]' <<< "$APPS")
    do
        local app_name=$(jq -r '.name' <<< "$app")
        echo - $app_name
        oc process -f appuio_${app_name}.yml --local=true --param-file=./envs/${env}/${app_name}/env > ./envs/${env}/${app_name}/${app_name}.yml
    done
}

ENV_CONFIGS=$(jq \
  '.environments' \
  $CONFIG_FILE)

for env in $(jq -c 'to_entries | map_values(.value + { name: .key })[]' <<< "$ENV_CONFIGS")
do
    ENV_NAME=$(jq -r '.name' <<< "$env")
    echo $ENV_NAME
    parse_env $env $ENV_NAME
    # echo $env
done



# echo $PROJECT_APPS

set +e