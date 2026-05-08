#!/usr/bin/env bash
set -ue

DOTFILES_ROOT=$(cd $(dirname $0); pwd)
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"

# /etc/os-release を読み込んで OS を特定
if [ -f /etc/os-release ]; then
    . /etc/os-release
    # ID は直接の識別子、ID_LIKE は派生元（ubuntu の ID_LIKE は debian など）
    case "$ID" in
        arch)
            OS="arch"
            ;;
        ubuntu|debian)
            OS="ubuntu"
            ;;
        *)
            # ID_LIKE もチェック（例: manjaro なら arch と判定させる）
            if [[ "${ID_LIKE:-}" == *"arch"* ]]; then
                OS="arch"
            elif [[ "${ID_LIKE:-}" == *"debian"* ]]; then
                OS="ubuntu"
            else
                echo "Unsupported OS: $ID"
                exit 1
            fi
            ;;
    esac
else
    echo "/etc/os-release not found. Unknown OS."
    exit 1
fi

echo "OS Detected: $ID (Targeting $OS config)"

mkdir -p ~/.local/bin
source "$HOME/.bashrc"

if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
  fi' >> ~/.bashrc
  source "$HOME/.bashrc"
fi

# 1. OS固有のインストール
bash "$SCRIPTS_DIR/$OS.sh"

if [ -f /usr/bin/batcat ]; then
    ln -s /usr/bin/batcat $HOME/.local/bin/bat
fi

cp -ri .config/. "$HOME/.config/"
zsh -c "zcompile $HOME/.zshrc"

if [ -f "$HOME/.zshrc.local" ]; then
    zsh -c "zcompile $HOME/.zshrc.local"
fi

echo "Setup complete!"