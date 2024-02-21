#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source $HOME/.config/zsg/variables
source $HOME/.config/zsh/aliases

PS1='[\u@\h \W]\$ '

# Run zsh
if [ command -v zsh &> /dev/null ]; then
  exec zsh
fi
