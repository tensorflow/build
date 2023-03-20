#!/usr/bin/env bash

curl -s https://api.github.com/graphql -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(jq -c -n --arg query "$(cat query.graphql)" '{"query":$query}')"
