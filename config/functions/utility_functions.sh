#!/bin/bash

# Show a pretty weather report for the specified city
weather() {
    curl -s "wttr.in/$1?format=🌄%20%S%20➡️%20%20%s%20🌃\n%c%t%20(feels%20like%20%f)\n"
}

# Function to handle copying with or without display
handle_copy() {
  local file="$1"
  local display="$2"

  if [[ -f "$file" ]]; then
    if [[ "$display" == "true" ]]; then
      # Display content using `bat` and copy to clipboard
      bat --color=never "$file" | pbcopy
      cat "$file"
    else
      # Copy content to clipboard without displaying
      bat --color=never "$file" | pbcopy
      echo "File content of '$file' copied to clipboard."
    fi
  else
    echo "File '$file' does not exist."
  fi
}

# Define functions for copy and copycat
copy() {
  handle_copy "$1" "false"
}

copycat() {
  handle_copy "$1" "true"
}


#
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}
