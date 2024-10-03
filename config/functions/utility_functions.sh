#!/bin/bash

# Show a pretty weather report for the specified city
weather() {
    curl -s "wttr.in/$1?format=🌄%20%S%20➡️%20%20%s%20🌃\n%c%t%20(feels%20like%20%f)\n"
}

# Run and copy the output to clipboard if 'copy' is passed as the last argument
run_and_copy() {
  if [[ "${@: -1}" == "copy" ]]; then
    output=$("${@:1:$(($#-1))}" 2>&1)
    echo "$output" | pbcopy
    bat --plain "$1" | pbcopy
  else
    "$@"
  fi
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
