#!/bin/zsh

echo "----------------------------------"
echo "  Welcome to the Dotfiles Setup"
echo "----------------------------------"

main_menu() {
  echo "1. Run ZSH Configuration Setup"
  echo "2. Run Homebrew Setup"
  echo "3. Run Cron Setup"
  echo "4. Run All Setups"
  echo "5. Exit"
  echo -n "Select an option: "
  read -r option
}

run_setup_script() {
  case "$1" in
  "zsh")
    echo "Running ZSH configuration setup..."
    source "$DOTFILES_HOME/config/zshrc"
    ;;
  "brew")
    echo "Running Homebrew setup..."
    bash "$DOTFILES_HOME/setup/brew/setup.sh"
    ;;
  "cron")
    echo "Running Cron setup..."
    bash "$DOTFILES_HOME/setup/cron/setup.sh"
    ;;
  "all")
    run_setup_script "zsh"
    run_setup_script "brew"
    run_setup_script "cron"
    ;;
  *)
    echo "Invalid option."
    ;;
  esac
}

while true; do
  main_menu
  case "$option" in
  1) run_setup_script "zsh" ;;
  2) run_setup_script "brew" ;;
  3) run_setup_script "cron" ;;
  4) run_setup_script "all" ;;
  5)
    echo "Exiting setup. Goodbye!"
    exit 0
    ;;
  *) echo "Invalid option. Please try again." ;;
  esac

  echo -n "Do you want to run another setup script? (y/n): "
  read -r run_another
  if [[ "$run_another" != "y" && "$run_another" != "Y" ]]; then
    echo "Exiting setup. Goodbye!"
    exit 0
  fi
done
