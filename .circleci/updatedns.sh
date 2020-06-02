#!/bin/bash
set -e

# Needed variables
TOKEN=$1  # The API v2 OAuth token
ACCOUNT_ID=$2        # Replace with your account ID
ZONE_ID=$3	  # The zone ID is the name of the zone (or domain)
RECORD_ID=$4	 
APPUIO_CNAME="cname.appuioapp.ch"
PROJECT_NAME=$5	

# Initial check
if [ -z "$TOKEN" ] || [ -z "$ACCOUNT_ID" ] || [ -z "$ZONE_ID" ] || [ -z "$RECORD_ID" ] || [ -z "$PROJECT_NAME" ]; then
  echo "ERROR: required variables are not specified, check your script invocation"
  exit 1
fi

function postData() 
{
	cat <<EOF
{
	"name": "$PROJECT_NAME",
	"type": "CNAME",
	"content": "$APPUIO_CNAME",
	"ttl": 600
}
EOF
}

# Create a new record
status_code=$(curl --write-out %{http_code} --silent --output /dev/null --request POST "https://api.dnsimple.com/v2/$ACCOUNT_ID/zones/$ZONE_ID/records" \
--header "Authorization: Bearer $TOKEN" \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data "$(postData)")
case "$status_code" in
	"201")
		echo "New record was successfully added to your domain";
		exit 0;
		;;
	"400")
		echo "ERROR: A required parameter or the request is invalid";
		exit 1;
		;;
	"401")
		echo "ERROR: Unauthenticated. Please make sure to add the required keys";
		exit 1;
		;;
	"500" | "502" | "503" | "504")
		echo "Uh oh, something went wrong on DNSimple’s end";
		exit 1;
		;;		
esac