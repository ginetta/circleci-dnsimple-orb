#!/bin/bash
set -e

# Needed variables
TOKEN=""  # The API v2 OAuth token
ACCOUNT_ID=""        # Replace with your account ID
ZONE_ID=""  # The zone ID is the name of the zone (or domain)
RECORD_ID=""       # Replace with the Record ID
APPUIO_CNAME="cname.appuioapp.ch"
PROJECT_NAME=""

# Initial check
if [ -z "$TOKEN" ] || [ -z "$ACCOUNT_ID" ] || [ -z "$ZONE_ID" ] || [ -z "$RECORD_ID" ] || [ -z "$PROJECT_NAME" ]; then
  echo "ERROR: required variables are not specified, check your script invocation"
  exit 1
fi


# Create a new record
curl --request POST "https://api.dnsimple.com/v2/$ACCOUNT_ID/zones/$ZONE_ID/records" \
--header "Authorization: Bearer $TOKEN" \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data @- <<END; 
{
	"name": "$PROJECT_NAME",
	"type": "CNAME",
	"content": "$APPUIO_CNAME",
	"ttl": 600
}
END