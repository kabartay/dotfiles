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

# ------------------------------
# Git identity from secrets
# ------------------------------
# Must be set in Codespaces secrets: FLEXAI_GIT_EMAIL (required), FLEXAI_GIT_NAME (optional)
if [ -n "${FLEXAI_GIT_EMAIL:-}" ]; then
  git config --global user.email "$FLEXAI_GIT_EMAIL"
else
  echo "❌ FLEXAI_GIT_EMAIL secret not set — commits won’t verify"
  exit 1
fi

if [ -n "${FLEXAI_GIT_NAME:-}" ]; then
  git config --global user.name "$FLEXAI_GIT_NAME"
else
  git config --global user.name "Codespaces User"
fi

# ------------------------------
# SSH commit signing setup
# ------------------------------
git config --global gpg.format ssh
git config --global user.signingkey "$KEY"
git config --global commit.gpgsign true
git config --global tag.gpgSign true

# ------------------------------
# Allowed signers file for local verification
# ------------------------------
mkdir -p ~/.config/git
EMAIL="$(git config user.email)"
PUBKEY="$(cat "${KEY}.pub")"
echo "${EMAIL} ${PUBKEY}" > ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
