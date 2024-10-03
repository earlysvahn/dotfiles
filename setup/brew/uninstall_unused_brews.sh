#!/bin/zsh

BREWFILE="$HOME/dotfiles/brew/Brewfile"

if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

  echo "Brewfile not found at $BREWFILE. Creating a new one from currently installed packages..."

  mkdir -p "$(dirname "$BREWFILE")" 
  brew bundle dump --file="$BREWFILE" --force
  echo "New Brewfile created at $BREWFILE."
  echo "Please review the generated Brewfile before running this script again."
  exit 0
fi

echo "Listing all installed Homebrew formulae and casks..."
installed_packages=($(brew list --formula --cask))

echo "Extracting packages defined in the Brewfile..."
brewfile_packages=($(grep -E '^brew|cask' "$BREWFILE" | awk '{print $2}' | tr -d '"' | sed 's/,//'))

echo "Identifying unused packages..."
unused_packages=()
for package in "${installed_packages[@]}"; do
  if [[ ! " ${brewfile_packages[@]} " =~ " ${package} " ]]; then
    echo "Unused package identified: $package"
    unused_packages+=("$package")
  fi
done

if [[ ${#unused_packages[@]} -eq 0 ]]; then
  echo "No unused packages found."
else
  echo "The following packages are not listed in the Brewfile:"
  for package in "${unused_packages[@]}"; do
    read "response?Do you want to uninstall $package? (y/n) "
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
      echo "Attempting to uninstall $package..."
      brew uninstall "$package" || {
        echo "Uninstallation failed due to dependencies."
        read "force_response?Would you like to force uninstall $package with --ignore-dependencies? (y/n) "
        if [[ "$force_response" == "y" || "$force_response" == "Y" ]]; then
          brew uninstall --ignore-dependencies "$package"
        else
          echo "Skipping forced uninstallation of $package."
        fi
      }
    else
      echo "Skipping uninstallation of $package."
    fi
  done
fi

echo "Uninstallation process completed."
