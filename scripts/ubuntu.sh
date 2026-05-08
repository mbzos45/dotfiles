#!/usr/bin/env bash
echo "--- Running Ubuntu/Debian-based setup (apt + binary) ---"

# apt で基本ツールをインストール
sudo apt update -y
sudo apt install -y  --no-install-recommends \
    bash-completion \
    zsh \
    fzf \
    bat \
    zoxide \
    curl \
    wget \
    git \
    build-essential \
    gcc \
    make \
    wget \
    mold

# rustup のインストール
if ! command -v rustup &>/dev/null; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # 現在のセッションでパスを通す
    source "$HOME/.cargo/env"
else
    echo "rustup is already installed. Updating..."
    rustup self update
    rustup update stable
fi

rustup default stable

# cargo-binstall の導入 (Rust製ツールの高速インストールのために便利)
if ! command -v cargo-binstall &>/dev/null; then
    echo "Installing cargo-binstall..."
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
fi

# sheldon (plugin manager)
if ! command -v sheldon &>/dev/null; then
    cargo binstall -y sheldon
fi

# mise (version manager) from apt repo
if ! command -v mise &>/dev/null; then
    sudo install -dm 755 /etc/apt/keyrings
    curl -fSs https://mise.en.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.en.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update -y
    sudo apt install -y mise
fi

if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.bak"
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
if [ -f "$HOME/.zshrc.local" ]; then
    echo "Backing up existing .zshrc.local to .zshrc.local.bak"
    mv "$HOME/.zshrc.local" "$HOME/.zshrc.local.bak"
fi

wget -O "$HOME/.zshrc"      https://grml.org/console/zshrc
wget -O "$HOME/.zshrc.local" https://grml.org/console/zshrc.local

echo 'if [ -f "$HOME/.config/zsh/local.zsh" ]; then
  source "$HOME/.config/zsh/local.zsh"
fi' >> "$HOME/.zshrc.local"



echo "Ubuntu setup script finished."