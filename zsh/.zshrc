# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

source $ZSH/oh-my-zsh.sh

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Function to reload .zshrc and .zprofile
reload_zsh_config() {
    source ~/.zshrc
    source ~/.zprofile
    echo "Reloaded ~/.zshrc and ~/.zprofile\r"
    zle accept-line
}

zle -N reload_zsh_config
bindkey '^Zr' reload_zsh_config