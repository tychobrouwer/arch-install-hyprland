# Oh My Zsh configuration
export ZSH="$HOME/Projects/oh-my-zsh"
ZSH_THEME="candy"
plugins=(git)
source $ZSH/oh-my-zsh.sh

bindkey -e

unsetopt beep

zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit

HISTFILE=$HOME/.histfile
HISTSIZE=1000
SAVEHIST=1000
HISTCONTROL=erasedups:ignoredups:ignorespace
CASE_SENSITIVE="true"

source $HOME/.config/zsh/variables
source $HOME/.config/zsh/functions
source $HOME/.config/zsh/aliases
source $HOME/.config/zsh/keybinds

# Show neofetch on shell startup
echo ""
neofetch_tiny
