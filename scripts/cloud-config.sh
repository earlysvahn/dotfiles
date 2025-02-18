#!/bin/zsh

# [[ -f ~/dotfiles/config/.env ]] && source ~/dotfiles/.env || { echo "Error: .env file not found in ~/dotfiles/"; exit 1; }

typeset -A env_map
env_map=(
	"dev" "$GCP_DEV_CONTEXT"
	"test" "$GCP_TEST_CONTEXT"
	"stage" "$GCP_TEST_CONTEXT"
	"prod" "$GCP_PROD_CONTEXT"
)

sorted_configurations=("dev" "stage" "test" "prod")

set_context() {
	local selected_env="$1"
	if [[ -z "$selected_env" || -z "${env_map[$selected_env]}" ]]; then
		echo "Invalid selection or environment mapping not found!"
		exit 1
	fi

	gcloud config configurations activate "$selected_env" >/dev/null 2>&1
	gcloud auth application-default set-quota-project "$selected_env" >/dev/null 2>&1
	kubectl config use-context "${env_map[$selected_env]}" >/dev/null 2>&1
}

select_env_with_fzf() {
	selected_env=$(printf "%s\n" "${sorted_configurations[@]}" | fzf --prompt="Select GCP Configuration: ")
	if [[ -n "$selected_env" && -n "${env_map[$selected_env]}" ]]; then
		set_context "$selected_env"
	else
		echo "No environment selected!"
		exit 1
	fi
}

show_active() {
	local current_context=$(kubectl config current-context)
	case "$current_context" in
		*"$GCP_DEV_CONTEXT"*) echo "dev" ;;
		*"$GCP_TEST_CONTEXT"*) echo "test" ;;
		*"$GCP_STAGE_CONTEXT"*) echo "stage" ;;
		*"$GCP_PROD_CONTEXT"*) echo "prod" ;;
		*) echo "$current_context" ;;
	esac
}

tool=""
action=""
env=""
use_fzf=false
use_current=false

while [[ "$#" -gt 0 ]]; do
	case $1 in
	-f | --fzf) use_fzf=true ;;         
	-c | --current) use_current=true ;; 
	cfg | k9s) tool=$1 ;;               
	set) action=$1 ;;                   
	dev | test | stage | prod) env=$1 ;;        
	*)
		echo "Ignoring invalid argument: $1"
		;;
	esac
	shift
done

if [[ "$tool" == "cfg" ]]; then
	if [[ -n "$env" ]]; then
		set_context "$env" 
	else
		select_env_with_fzf 
	fi

elif [[ "$tool" == "k9s" ]]; then
	if [[ "$use_fzf" = true ]]; then
		select_env_with_fzf
		k9s
	elif [[ "$use_current" = true ]]; then
		k9s
	elif [[ -n "$env" ]]; then
		set_context "$env"
		k9s
	else
		k9s
	fi

else
	echo "Invalid tool specified. Use 'cfg' or 'k9s'."
	exit 1
fi
