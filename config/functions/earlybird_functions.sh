#!/bin/bash

# Retrieve the access token from the specified environment and store it in the clipboard and environment variable
bnauth() {
	local env="${1:-dev}"
	local base_url
	local env_upper

	env_upper=$(echo "$env" | tr '[:lower:]' '[:upper:]')

	case "$env" in
	dev) base_url="$BIRDNEST_URL_DEV" ;;
	prod) base_url="$BIRDNEST_URL_PROD" ;;
	test) base_url="$BIRDNEST_URL_TEST" ;;
	stage) base_url="$BIRDNEST_URL_STAGE" ;;
	*) echo "Invalid environment specified. Use 'dev', 'prod', 'test', or 'stage'." && return 1 ;;
	esac

	if [[ -z "$BIRDNEST_USERNAME" || -z "$BIRDNEST_PASSWORD" || -z "$base_url" ]]; then
		echo "Error: BIRDNEST_USERNAME, BIRDNEST_PASSWORD, or URL for '$env' is not set."
		return 1
	fi

	local payload
	payload=$(jq -n --arg user "$BIRDNEST_USERNAME" --arg pass "$BIRDNEST_PASSWORD" \
		'{username: $user, password: $pass}')

	local response
	response=$(curl -s --location -X POST "$base_url/auth/token" \
		-H "Content-Type: application/json" \
		--data "$payload")

	local token
	token=$(echo "$response" | jq -r .token)

	if [[ "$token" == "null" || -z "$token" ]]; then
		echo "Error: Failed to retrieve access token from $base_url. Response: $response"
		return 1
	fi

	eval "export BIRDNEST_ACCESS_TOKEN_${env_upper}=\"$token\""
	echo "$token" | pbcopy
	echo "Access token successfully retrieved from $base_url, copied to clipboard, and stored in \$BIRDNEST_ACCESS_TOKEN_${env_upper}."
}
