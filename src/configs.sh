#!/usr/bin/env bash

set -e

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")

echo "SCRIPT_ROOT is $SCRIPT_ROOT"
echo "HOME is $HOME"

echo "(1/3) Setting up IDE..."
if command -v code &>/dev/null; then
  while IFS= read -r extension || [ -n "$extension" ]; do
      code --install-extension "$extension"
  done < "$SCRIPT_ROOT/configs/vscode/extensions"
  code --install-extension PKief.material-icon-theme
fi

if [ $(uname) = Darwin ]; then
	echo "(mac)"

	VSCODE_USER_SETTINGS_DIR=$HOME/Library/Application\ Support/Code/User
	mkdir -p "$VSCODE_USER_SETTINGS_DIR" && cp -f $SCRIPT_ROOT/configs/vscode/settings.json "$VSCODE_USER_SETTINGS_DIR"/settings.json

elif [ $(uname) = Linux ]; then
	if [ -n "$WSL_DISTRO_NAME" ]; then
		echo "(wsl)"

    WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')

		VSCODE_USER_SETTINGS_DIR=$WINDOWS_HOME/AppData/Roaming/Code/User
		mkdir -p $VSCODE_USER_SETTINGS_DIR && cp -f $SCRIPT_ROOT/configs/vscode/settings.json $VSCODE_USER_SETTINGS_DIR/settings.json
		# https://github.com/microsoft/vscode/issues/1022
		# https://github.com/microsoft/vscode/issues/166680

	elif [ -n "$CODESPACES" ]; then
		echo "(github codespaces)"
	else
		echo "(native linux)"

		VSCODE_USER_SETTINGS_DIR=$HOME/.config/Code/User
		mkdir -p $VSCODE_USER_SETTINGS_DIR && cp -f $SCRIPT_ROOT/configs/vscode/settings.json $VSCODE_USER_SETTINGS_DIR/settings.json
	fi
fi

echo "(2/3) Setting up terminal emulator..."
if [ $(uname) = Darwin ]; then
	echo "(mac)"

elif [ $(uname) = Linux ]; then
	if [ -n "$WSL_DISTRO_NAME" ]; then
		echo "(wsl)"

		WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')
    # Windows Terminal
		cp "$SCRIPT_ROOT/configs/windowsterminal/settings.json" ${WINDOWS_HOME}/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState/settings.json

	elif [ -n "$CODESPACES" ]; then
		echo "(github codespaces)"
	else
		echo "(native linux)"
	fi
fi

echo "(3/3) Setting up home files & permissions..."
configs=(
	.gitconfig
	.vimrc
	.zshrc
)
for config in "${configs[@]}"; do
  if [ -e "$HOME/$config" ]; then
    rm -rf "$HOME/$config"
    echo "Removed existing item at $HOME/$config"
  fi
	cp "$SCRIPT_ROOT/configs/$config" "$HOME/" && echo "Copied $SCRIPT_ROOT/configs/$config to $HOME/"
done;

rm -rf "$HOME/.config/nvim" && cp -r "$SCRIPT_ROOT/configs/nvim" "$HOME/.config/nvim" && echo "Copied $SCRIPT_ROOT/configs/nvim to $HOME/.config/nvim"

if [ -n "$WINDOWS_HOME" ]; then
  echo "(wsl)"
  ln -sf $HOME $WINDOWS_HOME/$(basename $HOME)
fi

if [ -z "$CODESPACES" ] && [ -d "$HOME/.ssh/" ]; then
    find $HOME/.ssh/ -type f -exec chmod 600 {} \;
    find $HOME/.ssh/ -type d -exec chmod 700 {} \;
    find $HOME/.ssh/ -type f -name "*.pub" -exec chmod 644 {} \;
fi

# gh auth login -h 'github.com' -p 'ssh' --skip-ssh-key -w
# https://gist.github.com/ridhwaans/08f2fc5e9b3614a3154cef749a43a568
mkdir -p "$HOME/Source" && curl -sfSL "https://gist.githubusercontent.com/ridhwaans/08f2fc5e9b3614a3154cef749a43a568/raw/scripts.sh" -o "$HOME/Source/scripts.sh" && chmod +x "$HOME/Source/scripts.sh"

# Moving to end because it lapses trailing code
vim +silent! +PlugInstall +PlugClean +qall

nvim --headless "+Lazy! sync" +qa

echo "Done!"

# Back to the original user
exit $?
