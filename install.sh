#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${SSH_SIGNING_KEY:-}" ]]; then
  mkdir -p ~/.ssh && chmod 700 ~/.ssh

  # write keys from Codespaces secrets
  printf '%s\n' "$SSH_SIGNING_KEY" > ~/.ssh/id_ed25519
  chmod 600 ~/.ssh/id_ed25519_signing

  if [[ -n "${SSH_SIGNING_PUB:-}" ]]; then
    printf '%s\n' "$SSH_SIGNING_PUB" > ~/.ssh/id_ed25519.pub
  else
    ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
  fi
  chmod 644 ~/.ssh/id_ed25519.pub

  # optional: load into agent for convenience
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519 || true

  # tell Git to sign with SSH, globally
  git config --global gpg.format ssh
  git config --global user.signingkey ~/.ssh/id_ed25519.pub
  git config --global commit.gpgsign true
  git config --global tag.gpgSign true
fi

