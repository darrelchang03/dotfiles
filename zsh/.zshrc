# --------------- PATH setup ----------------
typeset -U path
path=(
  /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
  /usr/lib/wsl/lib $HOME/.local/bin $HOME/.local/scripts $HOME/bin
)

autoload -U bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

[[ $- == *i* ]] || return

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

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}


addToPathFront $HOME/.local/bin
addToPathFront $HOME/.local/share/omarchy/bin
addToPathFront $HOME/.local/scripts
addToPathFront $HOME/.local/bin/miniconda3/condabin
addToPathFront $HOME/.local/bin/go/bin
addToPathFront $HOME/go/bin
addToPathFront $HOME/.cargo/bin


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
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


# Virutal environemnt manager
# -----------------------------------------------------------------------------
# include following in .bashrc / .bash_profile / .zshrc
# usage
# $ mkvenv myvirtualenv # creates venv under ~/.virtualenvs/
# $ venv myvirtualenv   # activates venv
# $ deactivate          # deactivates venv
# $ rmvenv myvirtualenv # removes venv

export VENV_HOME="$HOME/.virtualenvs"
[[ -d $VENV_HOME ]] || mkdir $VENV_HOME

lsvenv() {
  ls -1 $VENV_HOME
}

venv() {
  if [ $# -eq 0 ]
    then
      echo "Please provide venv name to activate"
    else
      source "$VENV_HOME/$1/bin/activate"
  fi
}

mkvenv() {
  if [ $# -eq 0 ]
    then
      echo "Please provide venv name to create"
    else
      python3 -m venv $VENV_HOME/$1
  fi
}

rmvenv() {
  if [ $# -eq 0 ]
    then
      echo "Please provide venv name to remove"
    else
      rm -r $VENV_HOME/$1
  fi
}

# For ROCm
export ROCM_PATH=/opt/rocm
export HSA_OVERRIDE_GFX_VERSION=11.0.0

# For linux gui apps to have a dbus
#if [[ $- == *i* ]] && command -v dbus-launch >/dev/null 2>&1; then
#    eval "$(dbus-launch --sh-syntax --exit-with-session)"
#fi

# Keep only entries that are dirs or symlinks to dirs
#_clean=()
#for d in $path; do
#  [[ -d $d || -L $d ]] && _clean+=$d
#done
#
## Ensure core dirs exist and are first (keep order stable)
#_must=( /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin )
#for d in $_must; do
#  [[ -d $d || -L $d ]] || continue
#  _clean=(${_clean:#$d})     # remove if present
#  _clean=($d $_clean)        # re-prepend
#done
#
#path=($_clean)
#unset _clean _must
#export PATH="${(j/:/)path}"


# Start tmux automatically if not already inside a session
# DO LAST SO THAT EVERYTHING BEFORE IT RUNS SMOOOTHLY
if [[ -z "$TMUX" ]]; then
    tmux attach || tmux new-session
fi

eval "$(zoxide init zsh)"
