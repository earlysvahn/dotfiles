# ~/dotfiles/config/aliases/common.nu

export alias ls = eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions
export alias mkdir = mkdir -v
export alias grep = grep -n --color
export alias x = exit
export alias path = copypath
export alias cat = bat -p
export alias c = copy
export alias cc = copycat
export alias tree = eza --tree -L 1 -A
export alias rmrf = rm -rf
export alias cd.. = cd ..
export alias .. = cd ..
export alias ... = cd ../../../
export alias .... = cd ../../../../
export alias ..... = cd ../../../../

export alias root = cd $nu.env.HOME/development

export alias b = bat
export alias bn = bat --number
export alias bnl = bat --number --line-range
export alias bp = bat --plain
export alias bpl = bat --plain --line-range
export alias bl = bat --line-range

# export alias bnenv = $nu.env.HOME/dotfiles/scripts/cloud-config.sh cfg
# export alias k9s = $nu.env.HOME/dotfiles/scripts/cloud-config.sh k9s
# export alias kube = $nu.env.HOME/Development/kube-tui/target/release/kube-tui

export alias vi = nvim
export alias vim = nvim
export alias view = nvim -R
export alias vimdiff = nvim -d
export alias oldvim = \vim
export alias notes = joplin
# export alias todos = bash $nu.env.HOME/dotfiles/scripts/joplin-todos.sh
# export alias ss = bash $nu.env.HOME/dotfiles/config/tmux/tmux-sessionizer.sh

export alias p = pnpm
export alias start = pnpm start
export alias install = pnpm install
export alias buni = bun install
export alias buna = bun add
export alias bunr = bun run --watch dev
export alias bunswag = bun run nswag
export alias bunup = bun upgrade
export alias tf = terraform
export alias dr = dotnet_run_fzf

export alias calendar = icalBuddy eventsToday+2
export alias spt = spotify_player

export def sptauth [] {
    cd $env.HOME/Desktop/librespot-auth
    cargo build
    mv credentials.json $env.HOME/.cache/spotify-player
}

export alias qmkc = qmk compile -kb keebio/iris/rev2 -km earlysvahn
export alias qmkf = cd $nu.env.HOME/qmk_firmware/keyboards/keebio/iris/keymaps

export alias wttr = curl -s "wttr.in/Nyköping?format=⛅ %S 🌡️ %s ☔\n%c%t (feels like %f)\n"
