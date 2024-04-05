#!/bin/bash

if command -v ssh &> /dev/null; then
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        # Generate a new ed25519 key
        ssh-keygen -t ed25519 -a 100 -C "$USER@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N ""
    fi

    # Start and enable ssh deamon
    sudo systemctl start sshd.service
    sudo systemctl enable sshd.service
fi
