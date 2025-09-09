#!/usr/bin/env bash
set -e

# Path to key
KEY="$HOME/.ssh/id_ed25519"

mkdir -p ~/.ssh

# Restore private key from secret
echo "$FLEXAI_CODESPACES" > "$KEY"
chmod 600 "$KEY"

# If you have a public key secret
if [ -n "${FLEXAI_CODESPACES_PUB:-}" ]; then
  echo "$FLEXAI_CODESPACES_PUB" > "${KEY}.pub"
else
  # Derive .pub from private key if not provided
  ssh-keygen -y -f "$KEY" > "${KEY}.pub"
fi

# Configure Git to use the PRIVATE key
git config --global gpg.format ssh
git config --global user.signingkey "$KEY"
git config --global commit.gpgsign true
git config --global tag.gpgSign true

# Local verification for `git log --show-signature`
mkdir -p ~/.config/git
printf "%s " "$(git config user.email)" > ~/.config/git/allowed_signers
cat "${KEY}.pub" >> ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
