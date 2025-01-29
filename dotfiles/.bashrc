#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source $HOME/.config/zsh/variables
source $HOME/.config/zsh/aliases

export CARGO_HOME=$HOME/.local/share/cargo
export RUSTUP_HOME=$HOME/.local/share/rustup

PS1='[\u@\h \W]\$ '
