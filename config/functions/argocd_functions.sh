#!/bin/bash

argoauth() {
	local env=$1

	if [[ -z $env ]]; then
		echo "Usage: argoauth <env>"
		echo "Available environments: dev, test, stage, prod"
		return 1
	fi

	local base_url
	case $env in
	dev)
		base_url="dev.earlybird.se"
		;;
	test)
		base_url="test.earlybird.se"
		;;
	stage)
		base_url="stage.earlybird.se"
		;;
	prod)
		base_url="api.earlybird.se"
		;;
	*)
		echo "Invalid environment: $env"
		echo "Available environments: dev, test, stage, prod"
		return 1
		;;
	esac

	echo "Logging into ArgoCD at $base_url..."
	if ! argocd login "$base_url" --sso --grpc-web-root-path argocd; then
		echo "Failed to log in to ArgoCD at $base_url."
		return 1
	fi
}

argor() {
	local app_name=$1

	if [[ -z $app_name ]]; then
		echo "Usage: argor <app_name>"
		return 1
	fi

	local output
	if ! output=$(argocd app get --refresh "$app_name" 2>/dev/null); then
		echo "Failed to fetch ArgoCD app details for $app_name."
		return 1
	fi

	echo "$output" | awk -v app_name="$app_name" '
    BEGIN { success=0; synced=0; total=0 }
    /Succeeded|Synced/ {
        total++
        if ($NF == "Succeeded" || $NF == "Synced") {
            if ($2 == "ConfigMap" || $2 == "ServiceAccount" || $2 == "Job") success++
            else if ($3 == "Healthy" || $NF == "unchanged") synced++
        }
    }
    END {
        if (success + synced == total) {
            print "ArgoCD app \"" app_name "\" summary: All resources are synced or succeeded (" total " total)."
        } else {
            print "ArgoCD app \"" app_name "\" sync/success summary:"
            print "Succeeded: " success
            print "Synced: " synced
            print "Total: " total
        }
    }'
}

argosync() {
	local app_name=$1

	if [[ -z $app_name ]]; then
		echo "Usage: argosync <app_name>"
		return 1
	fi

	echo "Syncing ArgoCD app \"$app_name\"..."
	if argocd app sync "$app_name"; then
		echo "App \"$app_name\" synced successfully."
	else
		echo "Failed to sync app \"$app_name\"."
		return 1
	fi
}

argolist() {
	echo "Fetching ArgoCD apps that are out of sync..."
	argocd app list --output json | jq -r '
    .[] | select(.status.sync.status != "Synced") | .metadata.name + " (Sync Status: " + .status.sync.status + ", Health Status: " + .status.health.status + ")"
  ' | {
		if read -r; then
			echo "$REPLY"
			cat
		else
			echo "All apps are synced."
		fi
	}
}
