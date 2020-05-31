#!/bin/bash
set -e

# Needed variables
TOKEN="T7vRc9e57kwVpld6t16HG2lwZAYC5dRX"  # The API v2 OAuth token
ACCOUNT_ID="90705"        # Replace with your account ID
ZONE_ID="ginetta.dev"  # The zone ID is the name of the zone (or domain)
RECORD_ID="1234567"       # Replace with the Record ID
APPUIO_CNAME="cname.appuioapp.ch"
PROJECT_NAME="orb-testing"

# Initial check
if [ -z "$TOKEN" ] || [ -z "$ACCOUNT_ID" ] || [ -z "$ZONE_ID" ] || [ -z "$PROJECT_NAME" ]; then
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