if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=( git zsh-syntax-highlighting zsh-autosuggestions web-search copypath dotnet jsontools macos brew alias-tips )

#tmux
export TMUX_CONFIG="$HOME/dotfiles/tmux/.tmux.conf"
tmux() {
    command tmux -f $TMUX_CONFIG "$@"
}
#tmux end 

[[ -f $HOME/dotfiles/env/.env ]] && source $HOME/dotfiles/env/.env || { echo "Error: .env file not found in $HOME/dotfiles/env/"; exit 1; }

export CLOUDSDK_PYTHON_SITEPACKAGES=1

source $ZSH/oh-my-zsh.sh
if [[ -f "$HOME/dotfiles/env/.env" ]]; then
    source "$HOME/dotfiles/env/.env"
else
    echo "Error: .env file not found in ~/dotfiles/"
    exit 1
fi

# Load functions
if [[ -d "$HOME/dotfiles/config/functions" ]]; then
    for function_file in "$HOME/dotfiles/config/functions"/*.sh; do
        [ -f "$function_file" ] && source "$function_file"
    done
fi

# Load aliases
if [[ -d "$HOME/dotfiles/config/aliases" ]]; then
    for alias_file in "$HOME/dotfiles/config/aliases/."*; do
        [ -f "$alias_file" ] && source "$alias_file"
    done
fi

# TMUX Configuration
export TMUX_CONFIG="$HOME/dotfiles/tmux/.tmux.conf"
tmux() {
    command tmux -f "$TMUX_CONFIG" "$@"
}

# Other configurations and exports (like PATH and NVM)
export PATH="$HOME/bin:/usr/local/bin:$PATH"
# (Include other relevant export PATH lines here)

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Load Powerlevel10k configuration
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

# Activate virtual environment
if [[ ! -f "$HOME/dotfiles/venv/bin/activate" ]]; then
  echo "Virtual environment not found. Creating it at $HOME/dotfiles/venv..."
  python3 -m venv "$HOME/dotfiles/venv"
  echo "Virtual environment created."
fi
source "$HOME/dotfiles/venv/bin/activate"

export PATH="/opt/homebrew/Cellar/omnisharp/1.35.3/libexec/bin:$PATH"
export PATH="/usr/local/share/dotnet:$PATH"
export PATH=$HOME/.dotnet/tools:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/fredriksvahn/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

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

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
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

eval "$(fzf --zsh)"
eval $(thefuck --alias)
eval $(thefuck --alias fk)
eval "$(zoxide init zsh)"

