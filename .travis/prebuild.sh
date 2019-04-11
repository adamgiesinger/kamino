#!/bin/bash

TIMESTAMP=$(date -u +%FT%TZ)

WEBHOOK_DATA='{
    "username": "ApolloTV (Travis)",
    "content": "A build has started.\n\nJob #'"$TRAVIS_JOB_NUMBER"' (Build #'"$TRAVIS_BUILD_NUMBER"') '"$STATUS_MESSAGE"' - '"$TRAVIS_REPO_SLUG"'\n\n'"$COMMIT_SUBJECT"'"
}'

(curl --fail --progress-bar -H Content-Type:application/json -d "$WEBHOOK_DATA" "$1" \
&& echo -e "\\n[Webhook]: Successfully sent the webhook.") || echo -e "\\n[Webhook]: Unable to send webhook."
