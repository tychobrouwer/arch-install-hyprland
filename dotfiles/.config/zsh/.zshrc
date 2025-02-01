# Oh My Zsh configuration
# export ZSH="~/.local/share/bin/oh-my-zsh"
# ZSH_THEME="candy"
# plugins=(git)
# source $ZSH/oh-my-zsh.sh

# starship configuration
eval "$(starship init zsh)"

bindkey -e

unsetopt beep

mkdir -p $HOME/.cache/zsh
zstyle :compinstall filename "$HOME/.config/zsh/.zshrc"
zstyle ':completion:*' cache-path $HOME/.cache/zsh

autoload -Uz compinit
compinit

HISTFILE=$HOME/.cache/zsh/history
HISTSIZE=1000
SAVEHIST=1000
HISTCONTROL=erasedups:ignoredups:ignorespace
CASE_SENSITIVE="true"

source $HOME/.config/zsh/variables
source $HOME/.config/zsh/functions
source $HOME/.config/zsh/aliases
source $HOME/.config/zsh/keybinds

# Load zsh-autosuggestions
source $HOME/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

# Load zsh search history with arrow keys
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Show neofetch on shell startup
# neofetch_tiny
fastfetch_tiny
