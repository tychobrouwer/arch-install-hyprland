source $HOME/.config/zsh/variables
source $HOME/.config/zsh/functions
source $HOME/.config/zsh/aliases
source $HOME/.config/zsh/keybinds

# If not running interactively, don't do anything and return early
[[ -o interactive ]] || exit 0

# Show neofetch on shell startup
echo ""
neofetch_tiny
