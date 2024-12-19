bws() {
  # Check if a search term is provided
  if [[ -z "$1" ]]; then
    echo "Usage: bws <search_term>"
    return 1
  fi

  # Fetch all items matching the search term and store them in a variable, suppressing warnings
  local items_json
  items_json=$(bw list items --search "$1" 2>/dev/null)

  # Prepare a list with "username (name)" format and include ID as a hidden field
  local selection
  selection=$(echo "$items_json" | jq -r '.[] | "\(.login.username) (\(.name))\t\(.id)"' | choose 2>/dev/null)

  # Extract the ID from the selected item
  local selected_id
  selected_id=$(echo "$selection" | awk -F '\t' '{print $2}')

  # Retrieve the password for the selected ID and copy it to the clipboard
  local password
  password=$(echo "$items_json" | jq -r --arg id "$selected_id" '.[] | select(.id == $id) | .login.password')

  # Copy the password to the clipboard
  echo "$password" | pbcopy

  echo "Password copied to clipboard."
}
