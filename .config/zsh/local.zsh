# Current Directory env
ZSHRC_DIR=${${(%):-%N}:A:h}

# override source
function source {
	ensure_zcompiled $1
	builtin source $1
}

# compile only file changed
function ensure_zcompiled {
	local compiled="$1.zwc"
	if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
		echo "\033[1;36mCompiled\033[m $1"
		zcompile $1
	fi
}

if [ -f "$ZSHRC_DIR/nonlazy.zsh" ]; then
	source $ZSHRC_DIR/nonlazy.zsh
fi

# load sheldon
export SHELDON_CONFIG_DIR="$HOME/.config/sheldon"
export SHELDON_CONFIG_FILE="$SHELDON_CONFIG_DIR/plugins.toml"
if type "sheldon" &>/dev/null; then
	sheldon_cache="$ZSHRC_DIR/sheldon.zsh"
	if [[ ! -r "$sheldon_cache" || "$SHELDON_CONFIG_FILE" -nt "$sheldon_cache" ]]; then
		command sheldon source > $sheldon_cache
	fi
	source $sheldon_cache
	unset sheldon_cache sheldon_toml
fi

# load starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
if type "starship" &>/dev/null; then
	starship_path=$(command -v starship)
	starship_cache="$ZSHRC_DIR/starship.zsh"
	if type "prompt" &>/dev/null; then
		prompt off
	fi
	if [[ ! -r "$starship_cache" || "$starship_path" -nt "$starship_cache" ]]; then
		command "$starship_path" init zsh > $starship_cache
	fi
	source $starship_cache
	unset starship_path
	unset starship_cache
fi

if type "zsh-defer" &>/dev/null; then
	if [ -f "$ZSHRC_DIR/lazy.zsh" ]; then
		zsh-defer source $ZSHRC_DIR/lazy.zsh
	fi
	zsh-defer unfunction source
else
	if [ -f "$ZSHRC_DIR/lazy.zsh" ]; then
		source $ZSHRC_DIR/lazy.zsh
	fi
	unfunction source
fi
