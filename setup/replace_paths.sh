#!/bin/bash

echo "-------------------------------------------"
echo "  Updating Dotfiles Paths for Current OS"
echo "-------------------------------------------"

if [[ "$OSTYPE" == "darwin"* ]]; then
  OLD_PATH="\$HOME/dotfiles"
  NEW_PATH="\$DOTFILES_HOME"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OLD_PATH="\$HOME/dotfiles"
  NEW_PATH="\$DOTFILES_HOME"
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  OLD_PATH="\$HOME/dotfiles"
  NEW_PATH="\$USERPROFILE/dotfiles"
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

echo "Replacing paths in configuration files:"
echo "Old Path: $OLD_PATH"
echo "New Path: $NEW_PATH"

find "$DOTFILES_HOME" -type f \( -name "*.sh" -o -name "*.zsh" -o -name "*.conf" \) -print0 | while IFS= read -r -d '' file; do
  sed -i.bak "s|$OLD_PATH|$NEW_PATH|g" "$file"
  echo "Updated: $file"
done

echo "Path update complete!"
