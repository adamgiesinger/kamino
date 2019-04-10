#!/bin/bash

TIMESTAMP=$(date -u +%FT%TZ)

WEBHOOK_DATA='{
    "username": "ApolloTV (Travis)",
    "content": "A build has started. Job #'"$TRAVIS_JOB_NUMBER"' (Build #'"$TRAVIS_BUILD_NUMBER"')\n\n`'"$TIMESTAMP"'`"
}'

(curl --fail --progress-bar -H Content-Type:application/json -d "$WEBHOOK_DATA" "$1" \
&& echo -e "\\n[Webhook]: Successfully sent the webhook.") || echo -e "\\n[Webhook]: Unable to send webhook."
