# =========================
# Zsh login profile (.zprofile)
# Keep minimal; no PATH edits, aliases, or zle here.
# =========================

# Make login shells run .zshrc too
[[ -r ${ZDOTDIR:-$HOME}/.zshrc ]] && . ${ZDOTDIR:-$HOME}/.zshrc


export XDG_CONFIG_HOME="$HOME/.config"

export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="$VIM"
export DOTFILES="$HOME/.dotfiles"

