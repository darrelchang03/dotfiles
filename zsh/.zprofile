addToPathFront() {
  if [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

export XDG_CONFIG_HOME=$HOME/.config
VIM="nvim"

export GIT_EDITOR=$VIM
export DOTFILES=$HOME/.dotfiles

addToPathFront $HOME/.local/bin
addToPathFront $HOME/.local/scripts
# addToPathFront $HOME/.dotfiles/bin/.local/scripts

# Where should I put you?
bindkey -s ^f "tmux-sessionizer\n"
