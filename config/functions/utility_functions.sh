
# Yazi
y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
# Create files with chmod +x
tx() {
    touch "$1"
    chmod +x "$1"
    echo "Created $1 with chmod +x"
}

# Display a pretty weather report for the specified city using wttr.in
weather() {
  curl -s "wttr.in/$1?format=???%20%S%20???%20%20%s%20??\n%c%t%20(feels%20like%20%f)\n"
}

# Handle copying file content to the clipboard, with optional display using `bat`
handle_copy() {
  local file="$1"
  local display="$2"

  if [[ -f "$file" ]]; then
    if [[ "$display" == "true" ]]; then
      bat --color=never "$file" | pbcopy
      cat "$file"
    else
      bat --color=never "$file" | pbcopy
      echo "File content of '$file' copied to clipboard."
    fi
  else
    echo "File '$file' does not exist."
  fi
}

hcopy() {
  if [[ -n "$1" ]]; then
    history | grep -i "$1" | tac | cut -d " " -f 3- | fzf | pbcopy
  else
    history | tac | cut -d " " -f 3- | fzf | pbcopy
  fi
}

# Copy file content to clipboard without displaying
copy() {
  handle_copy "$1" "false"
}

# Copy file content to clipboard and display using `bat`
copycat() {
  handle_copy "$1" "true"
}

# Custom FZF completion function for various commands
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    # Show a preview of directory contents using `eza` for the `cd` command
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    # Show variable contents for `export` or `unset`
    export|unset) fzf --preview "eval 'echo ${}'" "$@" ;;
    # Show DNS information for SSH hosts
    ssh)          fzf --preview 'dig {}' "$@" ;;
    # Default case: Use the provided preview command
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}


s() {
    local query="${*// /+}"
    open -a "Arc" "https://www.google.com/search?q=$query"
}

o() {
    local url="$1"
    
    if [[ ! "$url" =~ ^https?:// ]]; then
        url="https://$url"
    fi

    open "$url"
}

push_ubuntu() {
    if [[ -z "$1" ]]; then
        echo "Usage: push_ubuntu [-m] <file>"
        return 1
    fi

    local DEST="ubuntu:/media/fredrik/Roms/docs/"
    if [[ "$1" == "-m" ]]; then
        DEST="ubuntu:/media/movies/"
        shift  # Remove -m from arguments
    fi

    ssh ubuntu "mkdir -p $DEST"

    local FILE="$1"

    # Perform the file transfer with rsync
    if rsync -avP "$FILE" "$DEST"; then
        echo "Successfully moved $FILE to $DEST on Ubuntu!"
    else
        echo "Error: Failed to move $FILE"
    fi
}
