# --------------- PATH setup ----------------
typeset -U path
path=(
  /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
  /usr/lib/wsl/lib $HOME/.local/bin $HOME/.local/scripts $HOME/bin
)

# --------------- Functions -----------------
addToPathFront() {
    local d
    for d in "$@"; do
        [[ -d $d ]] || continue
        path=($d ${path:#$d})
    done
}

reload_zsh_config() {
    source ~/.zshrc
    source ~/.zprofile
    echo "Reloaded ~/.zshrc and ~/.zprofile\r"
    zle accept-line
}

addToPathFront $HOME/.local/bin
addToPathFront $HOME/.local/scripts
addToPathFront $HOME/.local/bin/miniconda3/condabin
addToPathFront $HOME/.local/bin/go/bin

# --------------- Keybinds -----------------
    bindkey -s ^f "tmux-sessionizer\n"
    zle -N reload_zsh_config
    bindkey '^Zr' reload_zsh_config

# --------------- Aliases -----------------
alias vim="nvim"
alias grep="rg"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# --------------- Oh my ZSH -----------------

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git fzf-tab)
source "$ZSH/oh-my-zsh.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# Start tmux automatically if not already inside a session
# DO LAST SO THAT EVERYTHING BEFORE IT RUNS SMOOOTHLY
if [[ -z "$TMUX" ]]; then
    tmux attach || tmux new-session
fi

# For linux gui apps to have a dbus
if [[ $- == *i* ]] && command -v dbus-launch >/dev/null 2>&1; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

# Keep only entries that are dirs or symlinks to dirs
_clean=()
for d in $path; do
  [[ -d $d || -L $d ]] && _clean+=$d
done

# Ensure core dirs exist and are first (keep order stable)
_must=( /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin )
for d in $_must; do
  [[ -d $d || -L $d ]] || continue
  _clean=(${_clean:#$d})     # remove if present
  _clean=($d $_clean)        # re-prepend
done

path=($_clean)
unset _clean _must
export PATH="${(j/:/)path}"
