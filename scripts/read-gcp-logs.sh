
#!/bin/zsh

# Retrieve the current GCP project
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)

if [[ -z "$CURRENT_PROJECT" ]]; then
    echo "Error: Unable to retrieve the active GCP project. Make sure you have configured it correctly."
    exit 1
fi

# Define the new log filter based on your provided query
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
    OR textPayload:"Graceful"
) 
AND NOT textPayload:"duplicate key value violates unique constraint"'

# Function to tail logs with the defined filter
function tail_gcp_logs() {
    echo "Tailing logs for project: $CURRENT_PROJECT"
    gcloud alpha logging tail "$LOG_FILTER" \
        --project="$CURRENT_PROJECT" \
        --user-output-enabled | yq -r '
        . as $root |
        "ERROR " + ($root.timestamp // "N/A") + " [" +
        "container_name: " + ($root.resource.labels.container_name // "unknown") + "] " +
        (
            if $root.json_payload.msg then
                $root.json_payload.msg
            elif $root.text_payload then
                $root.text_payload
            elif $root.http_request.request_url then
                "Request: " + $root.http_request.request_url + ", Status: " + ($root.http_request.status | tostring) + ", Method: " + $root.http_request.request_method
            else
                "No message available"
            end
        )
    '
}

# Run the function
tail_gcp_logs
