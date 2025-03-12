#!/bin/zsh

TMUX_DIR="$HOME/dotfiles/config/tmux"
TMUX_CONF="$TMUX_DIR/tmux.conf"
TMUX_RESET_CONF="$TMUX_DIR/tmux.reset.conf"
PLUGINS_DIR="$TMUX_DIR/plugins"
TPM_DIR="$PLUGINS_DIR/tpm"
SESSIONIZER_SCRIPT="$TMUX_DIR/tmux-sessionizer.sh"

echo "Do you want to check if tmux is installed and install it if missing? (y/n)"
read -r install_tmux
if [[ "$install_tmux" == "y" || "$install_tmux" == "Y" ]]; then
        if ! command -v tmux &>/dev/null; then
                echo "Tmux not found. Installing tmux..."
                brew install tmux
                echo "Tmux installed successfully."
        else
                echo "Tmux is already installed."
        fi
fi

echo "Do you want to set up tmux plugin manager (TPM)? (y/n)"
read -r setup_tpm
if [[ "$setup_tpm" == "y" || "$setup_tpm" == "Y" ]]; then
        if [[ ! -d "$TPM_DIR" ]]; then
                echo "Installing tmux plugin manager (TPM)..."
                git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
                echo "TPM installed successfully."
        else
                echo "TPM is already installed."
        fi
fi

echo "Do you want to set up the main tmux configuration file? (y/n)"
read -r setup_tmux_conf
if [[ "$setup_tmux_conf" == "y" || "$setup_tmux_conf" == "Y" ]]; then
        if [[ ! -f "$HOME/.tmux.conf" ]]; then
                ln -s "$TMUX_CONF" "$HOME/.tmux.conf"
                echo "Linked $TMUX_CONF to ~/.tmux.conf."
        else
                echo "tmux.conf already linked or present in the home directory."
        fi
fi

echo "Do you want to set up the tmux reset configuration file? (y/n)"
read -r setup_tmux_reset
if [[ "$setup_tmux_reset" == "y" || "$setup_tmux_reset" == "Y" ]]; then
        if [[ ! -f "$HOME/.tmux.reset.conf" ]]; then
                ln -s "$TMUX_RESET_CONF" "$HOME/.tmux.reset.conf"
                echo "Linked $TMUX_RESET_CONF to ~/.tmux.reset.conf."
        else
                echo "tmux.reset.conf already linked or present in the home directory."
        fi
fi

echo "Do you want to set up the tmux sessionizer script? (y/n)"
read -r setup_sessionizer
if [[ "$setup_sessionizer" == "y" || "$setup_sessionizer" == "Y" ]]; then
        mkdir -p "$HOME/.tmux/scripts"
        ln -sf "$SESSIONIZER_SCRIPT" "$HOME/.tmux/scripts/tmux-sessionizer.sh"
        echo "Linked $SESSIONIZER_SCRIPT to ~/.tmux/scripts."
fi

echo "Do you want to source the new tmux configuration? (y/n)"
read -r source_conf
if [[ "$source_conf" == "y" || "$source_conf" == "Y" ]]; then
        tmux source-file "$HOME/.tmux.conf"
fi

echo "Do you want to install tmux plugins using TPM? (y/n)"
read -r install_plugins
if [[ "$install_plugins" == "y" || "$install_plugins" == "Y" ]]; then
        "$TPM_DIR/bin/install_plugins"
fi

echo "Do you want to start a new tmux session? (y/n)"
read -r start_session
if [[ "$start_session" == "y" || "$start_session" == "Y" ]]; then
        tmux new-session
fi

echo "Tmux setup completed."
