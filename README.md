# dotfiles

[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)](install.sh)
[![Codespaces](https://img.shields.io/badge/GitHub-Codespaces-181717?logo=github)](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles)

Signed commits in every GitHub Codespace, with no manual setup.

When a codespace starts, GitHub clones this repository and runs [`install.sh`](install.sh). The script reads an SSH key from a Codespaces secret and sets Git to sign every commit and tag with it, so they show as **Verified** on GitHub.

## What the script does

If the `SSH_SIGNING_KEY` secret is set:

1. It writes the private key to `~/.ssh/id_ed25519` (mode `600`).
2. It writes the public key to `~/.ssh/id_ed25519.pub`, taking it from `SSH_SIGNING_PUB` if that secret exists or deriving it from the private key otherwise.
3. It loads the key into `ssh-agent`.
4. It sets this global Git configuration:

   ```ini
   [gpg]
       format = ssh
   [user]
       signingkey = ~/.ssh/id_ed25519.pub
   [commit]
       gpgsign = true
   [tag]
       gpgSign = true
   ```

If the secret is not set, the script does nothing, so the repository is safe to keep enabled everywhere.

## Setup (once)

1. **Make a signing key** without a passphrase, since a codespace has no one to type it:

   ```bash
   ssh-keygen -t ed25519 -C "codespaces signing" -N "" -f ./codespaces_signing
   ```

2. **Register it with GitHub.** Open [Settings → SSH and GPG keys](https://github.com/settings/keys) and choose **New SSH key**. Set **Key type** to **Signing Key** and paste `codespaces_signing.pub`.

3. **Store it as Codespaces secrets.** Open [Settings → Codespaces → Secrets](https://github.com/settings/codespaces), add the secrets below, and give them access to the repositories you work in:

   | Secret | Value | Required |
   | --- | --- | --- |
   | `SSH_SIGNING_KEY` | the full contents of `codespaces_signing`, including the `BEGIN`/`END` lines | yes |
   | `SSH_SIGNING_PUB` | the contents of `codespaces_signing.pub` | no, derived if missing |

4. **Turn on dotfiles.** On the same [Codespaces settings](https://github.com/settings/codespaces) page, tick **Automatically install dotfiles** and pick this repository.

5. Delete the local key files. They now exist only as secrets and on GitHub.

## Check it works

In a new codespace:

```bash
git config --global --get gpg.format          # ssh
git commit --allow-empty -m "test: signing"
git log --show-signature -1                    # see the note below
git push                                       # GitHub shows "Verified"
```

`git log --show-signature` prints *"gpg.ssh.allowedSignersFile needs to be configured"*. That only affects checking signatures locally; the commit is signed, and GitHub verifies it.

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| Commits show **Unverified** on GitHub | The key was added as an *Authentication* key, not a *Signing* key, or the commit email is not a verified address on your account. |
| `error: Load key ... invalid format` | The secret lost its line breaks or the `BEGIN`/`END` lines. Paste the whole file again. |
| Nothing happens | The secret isn't available to this repository (step 3), or dotfiles aren't enabled (step 4). Codespaces logs the dotfiles step in `/workspaces/.codespaces/.persistedshare/creation.log`. |
| Changes to the script have no effect | Dotfiles run only when a codespace is created. Rebuild the codespace or make a new one. |

## Security notes

- The private key lives in a Codespaces secret and in each codespace's `~/.ssh`. Use a key made only for signing, and revoke it on GitHub if a codespace is ever shared or exposed.
- The script overwrites `~/.ssh/id_ed25519` in the codespace. A fresh codespace has no such file, but keep that in mind if you run it by hand somewhere else.
- No key material is stored in this repository.
