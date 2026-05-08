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
    sccache \
    mold


source /etc/profile.d/rustup.sh
rustup default stable

if ! command -v paru &>/dev/null; then
    echo "Installing paru..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru-build
    (cd /tmp/paru-build && makepkg -si --noconfirm)
    rm -rf /tmp/paru-build
fi

if ! command -v cargo-binstall &>/dev/null; then
    echo "Installing cargo-binstall..."
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
    cargo binstall -y cargo-update
fi

if [[ "${INSTALL_STARSHIP:-0}" == "1" ]]; then
    if ! command -v starship &>/dev/null; then
        echo "Installing starship..."
        sudo pacman -S --noconfirm starship
    fi
fi

if ! command -v mise &>/dev/null; then
    curl https://mise.run | sh
    mise completion bash > $HOME/.local/share/bash-completion/completions/mise
    mise completion zsh > $HOME/.zfunc/_mise
fi

echo "alias p='sudo pacman -Syu; paru -Sua; rustup update ; cargo install-update -a ; mise self-update; mise up'" >> "$DOTFILES_CONFIG_DIR/zsh/lazy.zsh"

echo 'if [ -f "$HOME/.config/zsh/local.zsh" ]; then
  source "$HOME/.config/zsh/local.zsh"
fi' >> "$HOME/.zshrc"