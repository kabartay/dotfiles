# Ensure a signing key exists
KEY="$HOME/.ssh/id_ed25519_codespaces"

if [ ! -f "$KEY" ]; then
  ssh-keygen -t ed25519 -C "$(git config user.email)" -f "$KEY" -N ""
fi

# Configure Git to use it
git config --global gpg.format ssh
git config --global user.signingkey "$KEY"
git config --global commit.gpgsign true
git config --global tag.gpgSign true

# Set up local verification (optional)
mkdir -p ~/.config/git
printf "%s " "$(git config user.email)" > ~/.config/git/allowed_signers
cat "$KEY.pub" >> ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
