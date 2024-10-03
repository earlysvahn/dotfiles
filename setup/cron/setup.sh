#!/bin/zsh

if [[ -f "$HOME/dotfiles/cron/my_crontab" ]]; then
  crontab "$HOME/dotfiles/cron/my_crontab"
  echo "Crontab has been successfully set up from dotfiles!"
else
  echo "Crontab file not found in dotfiles."
fi
