export XDG_CONFIG_HOME=$HOME/.config
export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
plugins=( git zsh-syntax-highlighting zsh-autosuggestions copypath dotnet macos brew alias-tips git-auto-fetch vi-mode)

[[ -f $HOME/dotfiles/env/.env ]] && source $HOME/dotfiles/env/.env || { echo "Error: .env file not found in $HOME/dotfiles/env/"; exit 1; }

export CLOUDSDK_PYTHON_SITEPACKAGES=1

source $ZSH/oh-my-zsh.sh
if [[ -f "$HOME/dotfiles/env/.env" ]]; then
    source "$HOME/dotfiles/env/.env"
else
    echo "Error: .env file not found in $HOME/dotfiles/"
    exit 1
fi


# TMUX Configuration
export TMUX_CONFIG="$HOME/dotfiles/config/tmux/.tmux.conf"
tmux() {
    command tmux -f "$TMUX_CONFIG" "$@"
}


# Load functions
if [[ -d "$HOME/dotfiles/config/functions" ]]; then
    for function_file in "$HOME/dotfiles/config/functions"/*.sh; do
        [ -f "$function_file" ] && source "$function_file"
    done
fi


# Other configurations and exports (like PATH and NVM)
export PATH="$HOME/bin:/usr/local/bin:$PATH"
# (Include other relevant export PATH lines here)

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Load Powerlevel10k configuration
# [[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

export PATH="/opt/homebrew/Cellar/omnisharp/1.35.3/libexec/bin:$PATH"
export PATH="/usr/local/share/dotnet:$PATH"
export PATH=$HOME/.dotnet/tools:$PATH
export PATH="$HOME/go/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/fredriksvahn/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pnpm
export PNPM_HOME="/Users/fredriksvahn/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
test -e /Users/fredriksvahn/.iterm2_shell_integration.zsh && source /Users/fredriksvahn/.iterm2_shell_integration.zsh || true

# bun completions
[ -s "/Users/fredriksvahn/.bun/_bun" ] && source "/Users/fredriksvahn/.bun/_bun"

eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval $(thefuck --alias)
eval $(thefuck --alias fk)
eval "$(zoxide init zsh)"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#2dd4bf"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_TMUX_OPTS=" -p90%,70% "  
#
# Load aliases last due to plugin issues
if [[ -d "$HOME/dotfiles/config/aliases" ]]; then
    for alias_file in "$HOME/dotfiles/config/aliases/."*; do
        [ -f "$alias_file" ] && source "$alias_file"
    done
fi


GIT_AUTO_FETCH_INTERVAL=60
