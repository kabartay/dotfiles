#!/usr/bin/env bash
set -e

KEY="$HOME/.ssh/id_ed25519"

# Generate signing key if missing
if [ ! -f "$KEY" ]; then
  mkdir -p ~/.ssh
  ssh-keygen -t ed25519 -C "$(git config user.email)" -f "$KEY" -N ""
fi

# Configure Git to use the PRIVATE key (not .pub!)
git config --global gpg.format ssh
git config --global user.signingkey "$KEY"
git config --global commit.gpgsign true
git config --global tag.gpgSign true

# Optional: set up local verification so `git log --show-signature` works
mkdir -p ~/.config/git
printf "%s " "$(git config user.email)" > ~/.config/git/allowed_signers
cat "${KEY}.pub" >> ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
