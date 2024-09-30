#!/bin/zsh

# Load environment variables from the .env file
if [[ -f ~/dotfiles/.env ]]; then
	source ~/dotfiles/.env
else
	echo "Error: .env file not found in ~/dotfiles/"
	exit 1
fi

# Retrieve the current GCP project
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)

if [[ -z "$CURRENT_PROJECT" ]]; then
	echo "Error: Unable to retrieve the active GCP project. Make sure you have configured it correctly."
	exit 1
fi

# Define a log filter to capture ERRORs and specific HTTP status codes and container names
LOG_FILTER='(
    severity=ERROR 
    OR httpRequest.status=404 
    OR httpRequest.status=403 
    OR httpRequest.status=402 
    OR httpRequest.status=401 
    OR httpRequest.status=400 
    OR resource.labels.container_name="istio-proxy" 
    OR resource.labels.container_name="sftp" 
    OR resource.labels.container_name="metrics-server" 
    OR resource.labels.container_name="gke-metadata-server"
    OR textPayload: "Graceful"
) 
AND NOT textPayload:"duplicate key value violates unique constraint"'

# Function to read and format logs continuously
tail_logs() {
	while true; do
		gcloud logging read "$LOG_FILTER" \
			--project="$CURRENT_PROJECT" \
			--format="json" \
			--limit=100 --order=desc | jq -r '
                .[] |
                select(.textPayload != null or .jsonPayload.message != null or .protoPayload.message != null) |
                (if .resource.labels.container_name == "sftp" then "\u001b[31m" else "\u001b[0m" end) + 
                "\(.timestamp | sub("T"; " ") | sub("Z"; "") | split(" ") | .[0] | split("-") | .[2] + "/" + .[1] + "-" + .[0]) [\(.resource.labels.container_name)] \(.textPayload // .jsonPayload.message // .protoPayload.message)" + "\u001b[0m"
            ' | bat --language=log --style=plain

		sleep 2 # Wait for 2 seconds before checking logs again
	done
}

# Start tailing logs
tail_logs
