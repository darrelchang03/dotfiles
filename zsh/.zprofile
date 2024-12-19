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

# Where should I put you?
bindkey -s ^f "tmux-sessionizer\n"

alias vim="nvim"
alias grep="rg"

# Function to reload .zshrc and .zprofile
reload_zsh_config() {
    source ~/.zshrc
    source ~/.zprofile
    echo "Reloaded ~/.zshrc and ~/.zprofile\r"
    zle accept-line
}

zle -N reload_zsh_config
bindkey '^Zr' reload_zsh_config

