#!/bin/bash
stock() {
	local stock_id="$1"
	result=$(curl -s "https://www.avanza.se/_api/market-guide/stock/$stock_id" | jq --arg stock_id "$stock_id" -r '{name} + (.quote | {last, highest, lowest})')
	name=$(echo "$result" | jq -r '.name')
	last=$(echo "$result" | jq -r '.last')
	highest=$(echo "$result" | jq -r '.highest')
	lowest=$(echo "$result" | jq -r '.lowest')

	color_last="\033[33m"    # yellow
	color_lowest="\033[31m"  # red
	color_highest="\033[32m" # green
	color_reset="\033[0m"    # reset color

	echo -e "$name - ${color_last}${last}${color_reset} (${color_lowest}${lowest}${color_reset}/${color_highest}${highest}${color_reset})"
}

stocks() {
	local stock_ids=("1523003" "118370")
	local divider="\033[90m----------------------------------------\033[0m" # Dark gray divider

	while true; do
		echo -e "$(date +'%-d/%-m %H:%M')"

		for id in "${stock_ids[@]}"; do
			stock "$id"
		done

		echo -e "${divider}"

		sleep 300
	done
}
