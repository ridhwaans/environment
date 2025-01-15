#!/usr/bin/env bash

rm -rf ~/.local/share/environment
git clone https://github.com/ridhwaans/environment.git ~/.local/share/environment

echo "Installation starting..."
source ~/.local/share/environment/install.sh
