#!/usr/bin/env bash
# Phase 1 · PREPARE the system — apt packages, zsh, oh-my-zsh, login shell.
# YOU run this: it uses sudo (your password) more than once.
# Nothing here comes from this repo; it's the ground everything else stands on.

APT_BASE="ca-certificates software-properties-common curl unzip git build-essential stow zsh"
APT_TOOLS="git podman"
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

echo
echo "==> [1/4] core apt packages"
sudo apt update
sudo apt install -y $APT_BASE

echo
echo "==> [2/4] system tools · newer git from ppa:git-core/ppa (2.43 -> 2.5x), podman"
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y $APT_TOOLS

echo
echo "==> [3/4] oh-my-zsh + plugins"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo
echo "==> [4/4] zsh as login shell · takes effect on the next login, not in this shell"
chsh -s "$(which zsh)"

echo
echo "==> prepare done.  Next:  scripts/02-setup.sh"
