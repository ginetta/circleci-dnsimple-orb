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
# Default domain for apps
DEFAULT_DOMAIN="ginetta.dev"
# Default protocol for apps
DEFAULT_PROTOCOL="https"
# Default path for apps
DEFAULT_PATH=""


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

  # -a|--app: Environment to configure for
  case $key in
    -a|--app)
    CURRENT_APP="$2"
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

if [ -z "$ENV" ]; then
  echo "ERROR: env not specified, -e or --env argument must be specified, check your script invocation"
  exit 1
fi

if [ -z "$CURRENT_APP" ]; then
  echo "ERROR: app not specified, -a or --app argument must be specified, check your script invocation"
  exit 1
fi

# Function to add an env var
# Arguments:
#   $1 Env var name
#   $2 Env var value
add_to_envs () {
    local name="$(echo $1 | tr [a-z] [A-Z])"
    local value="$(echo $2)"

    echo "export ${name}=\"${value}\"" >> $BASH_ENV
    echo "Added ${name}=\"${value}\""

}

# Function to prefix the env var with
#   ${ENV}_${APP}_
#   and if the app is the current one:
#   APP_
# Arguments:
#   Same as `add_to_envs`
add_to_app_envs () {
  local prefix=$(echo "${APP}_" | tr [a-z] [A-Z])
  add_to_envs "${prefix}${@}"

  if [[ "${APP}" == "${CURRENT_APP}" ]]; then
    add_to_envs "APP_${@}"
  fi

}

set_environment_variables () {
    local envconfig="$1"
    local APPUIO_PROJECT=$(jq -r '.appuio_project' <<< "$envconfig")
    add_to_envs "APPUIO_PROJECT" "${APPUIO_PROJECT}" false


    # local APPUIO_TOKEN=$(jq -r '.appuio_token' <<< "$envconfig")
    # add_to_envs "APPUIO_TOKEN" "${APPUIO_TOKEN}" false
}

# Function to parse the ENV vars we want to build for each apps
# Arguments:
#   $1 jq object of the app config
# Output:
#   {APP}_NAME
#   {APP}_ALIAS
#   {APP}_PROTOCOL
#   {APP}_HOSTNAME
#   {APP}_PATH
#   {APP}_PORT
#   APP_NAME
#   APP_ALIAS
#   APP_PROTOCOL
#   APP_HOSTNAME
#   APP_PATH
#   APP_PORT
set_app_variables () {
    local appconfig="$1"
    local APP=$(jq -r '.name' <<< "$appconfig")
    add_to_app_envs "NAME" "${APP}" false

    local ALIAS=$(jq -r '.alias' <<< "$appconfig")
    add_to_app_envs "ALIAS" "${ALIAS}" false

    local PROTOCOL="$(echo ${ALIAS} | grep :// | sed -e's,^\(.*://\).*,\1,g')"
    add_to_app_envs "PROTOCOL" "${PROTOCOL}" false

    local URL="$(echo ${ALIAS/$PROTOCOL/})"
    local HOSTNAME="$(echo ${URL} | cut -d/ -f1)"
    add_to_app_envs "HOSTNAME" "${HOSTNAME}" false

    local DEPLOY_PATH="$(echo $URL | grep / | cut -d/ -f2- )"

    if [[ ! -z "$DEPLOY_PATH" ]]; then
      DEPLOY_PATH="$(echo /$DEPLOY_PATH)"
    fi

    add_to_app_envs "PATH" "${DEPLOY_PATH}" false


    local PORT=$(jq -r '.port' <<< "$appconfig")
    add_to_app_envs "PORT" "${PORT}" false
}

ENV_CONFIG=$(jq \
  --arg env "${ENV}" \
  '.environments[$env]' \
  $CONFIG_FILE)

PROJECT_APPS=$(jq \
  --arg env "${ENV}" \
  '.environments[$env].apps' \
  $CONFIG_FILE)

if [[ -z "$PROJECT_APPS" ]] || [[ "$PROJECT_APPS" == "null" ]]; then
    echo "ERROR: no apps config found for the defined for the environement ${ENV}"
    exit 1
fi

set_environment_variables "$ENV_CONFIG"

for app in $(jq -c 'to_entries | map_values(.value + { name: .key })[]' <<< "$PROJECT_APPS")
do
    echo "--"
    set_app_variables "$app"
done

source $BASH_ENV

set +e