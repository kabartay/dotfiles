# Ensure signing key is restored from Codespaces secret
KEY="$HOME/.ssh/id_ed25519_codespaces"
mkdir -p ~/.ssh

if [ ! -f "$KEY" ]; then
  echo "$SIGNING_KEY" > "$KEY"
  chmod 600 "$KEY"
fi

# Configure Git to use it
git config --global gpg.format ssh
git config --global user.signingkey "$KEY"
git config --global commit.gpgsign true
git config --global tag.gpgSign true

# Local verification (optional)
mkdir -p ~/.config/git
printf "%s " "$(git config user.email)" > ~/.config/git/allowed_signers
cat "$KEY.pub" >> ~/.config/git/allowed_signers 2>/dev/null || true
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
