#!/bin/zsh

BREWFILE="$HOME/dotfiles/brew/Brewfile"

if ! command -v brew &>/dev/null; then
  echo "Homebrew is not installed. Do you want to install it? (y/n)"
  read -r install_response
  if [[ "$install_response" == "y" || "$install_response" == "Y" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Homebrew installed successfully."
  else
    echo "Skipping Homebrew installation. Exiting script."
    exit 1
  fi
else
  echo "Homebrew is already installed."
fi

if [[ ! -f "$BREWFILE" ]]; then
  echo "Brewfile not found at $BREWFILE. Please make sure you've committed the Brewfile to your dotfiles. Exiting."
  exit 1
else
  echo "Brewfile found at $BREWFILE."
fi

brew bundle check --file="$BREWFILE"

echo "Do you want to install missing packages listed in the Brewfile? (y/n)"
read -r response
if [[ "$response" == "y" || "$response" == "Y" ]]; then
  brew bundle --file="$BREWFILE"
else
  echo "Skipping installation of missing packages."
fi

echo "Do you want to clean up packages not listed in the Brewfile? (y/n)"
read -r cleanup_response
if [[ "$cleanup_response" == "y" || "$cleanup_response" == "Y" ]]; then
  brew bundle cleanup --file="$BREWFILE"
else
  echo "Skipping cleanup of extra packages."
fi

echo "Updating Homebrew and upgrading all installed packages..."
brew update
brew upgrade

echo "Running brew autoremove to remove unused dependencies..."
brew autoremove --verbose --debug

echo "Running brew cleanup to remove old versions and cache..."
brew cleanup

echo "Do you want to run brew doctor to check for any issues? (y/n)"
read -r doctor_response
if [[ "$doctor_response" == "y" || "$doctor_response" == "Y" ]]; then
  brew doctor | tee "$HOME/dotfiles/brew/brew_doctor_log.txt"
  echo "brew doctor output saved to $HOME/dotfiles/brew/brew_doctor_log.txt"
else
  echo "Skipping brew doctor."
fi

echo "Homebrew setup and cleanup completed successfully!"
