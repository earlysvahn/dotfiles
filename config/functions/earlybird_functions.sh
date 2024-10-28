# Retrieve the access token from the specified environment and store it in the clipboard and environment variable
bnauth() {
	local env="${1:-dev}"
	local quiet=false
	local base_url
	local env_upper

	# Parse optional arguments
	shift
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-q | --quiet)
			quiet=true
			shift
			;;
		*)
			echo "Unknown option: $1"
			return 1
			;;
		esac
	done

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

	# Conditionally echo the success message based on the quiet flag
	if [[ "$quiet" == false ]]; then
		echo "Access token successfully retrieved from $base_url, copied to clipboard, and stored in \$BIRDNEST_ACCESS_TOKEN_${env_upper}."
	fi
}

bomb_usage() {
	local txt=(
		"bomb is a tool to run load tests against different environments using bombardier."
		"Usage: bomb <environment> <tracking_id> [options]"
		""
		"Environment:"
		"  dev, test, stage, prod  The target environment for the test."
		""
		"Options:"
		"  -c <concurrent>         Number of concurrent requests (default: 10)."
		"  -d <duration>           Duration of the test (default: 30s)."
		"  --cid <customer_id>     Optional customer ID."
		"  -h, --help              Display this help message."
		""
		"Examples:"
		"  bomb dev 1234               # Run with default settings (10 concurrent, 30s)."
		"  bomb prod 5678 -c 20        # Run with 20 concurrent requests for 30s."
		"  bomb stage 9101 -d 60s      # Run for 60 seconds with 10 concurrent requests."
		"  bomb test 1112 --cid 42     # Include a customer ID in the request."
	)

	printf "%s\\n" "${txt[@]}"
}

bomb() {
	local env
	local tracking_id
	local customer_id=""
	local concurrent=10
	local duration=30s

	env=$1
	tracking_id=$2

	if [[ "$env" == "-h" || "$env" == "--help" ]]; then
		bomb_usage
		return 0
	fi

	shift 2
	while [[ $# -gt 0 ]]; do
		case $1 in
		-c)
			concurrent=$2
			shift 2
			;;
		-d)
			duration=$2
			shift 2
			;;
		-cid)
			customer_id=$2
			shift 2
			;;
		*)
			echo "Unknown option: $1"
			bomb_usage
			return 1
			;;
		esac
	done

	if [[ -z "$env" || -z "$tracking_id" ]]; then
		bomb_usage
		return 1
	fi

	echo "Bombing $env for ${duration} with ${concurrent} concurrent requests..."

	local env_upper=${env:u}
	local base_url_var="BIRDNEST_URL_${env_upper}"
	local base_url
	base_url=$(eval echo "\$$base_url_var")

	if [[ -z "$base_url" ]]; then
		echo "Error: Base URL for $env is not set."
		return 1
	fi

	bnauth $env -q

	local access_token_var="BIRDNEST_ACCESS_TOKEN_${env_upper}"
	local access_token
	access_token=$(eval echo "\$$access_token_var")

	if [[ -z "$access_token" ]]; then
		echo "Error: Access token for $env is not set."
		return 1
	fi

	local url="${base_url}/munin-api/v1/status/${tracking_id}/latest"
	[[ -n "$customer_id" ]] && url="${url}?customer-id=${customer_id}"

	bombardier -c "$concurrent" -d "$duration" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $access_token" \
		-m GET "$url"
}
