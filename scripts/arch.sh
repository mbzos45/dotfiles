#!/usr/bin/env bash
echo "--- Running Arch-based setup (pacman + binary) ---"

sudo pacman -Rsn --noconfirm $(pacman -Qq | grep '^cargo-') 



sudo pacman -Syu --noconfirm \
    bash-completion \
    grml-zsh-config \
    zsh-completions \
    fzf \
    bat \
    zoxide \
    curl \
    wget \
    git \
    base-devel \
    rustup \
    mise \
    sheldon \
    mold


source /etc/profile.d/rustup.sh
rustup default stable

if ! command -v cargo-binstall &>/dev/null; then
    echo "Installing cargo-binstall..."
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
fi

if ! command -v mise &>/dev/null; then
    curl https://mise.run | sh
fi

if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.bak"
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

if [ -f "$HOME/.zshrc.local" ]; then
    echo "Backing up existing .zshrc.local to .zshrc.local.bak"
    mv "$HOME/.zshrc.local" "$HOME/.zshrc.local.bak"
fi

echo 'if [ -f "$HOME/.config/zsh/local.zsh" ]; then
  source "$HOME/.config/zsh/local.zsh"
fi' >> "$HOME/.zshrc"