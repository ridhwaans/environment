# environment
 https://github.com/ridhwaans/environment

git
```bash
git clone https://github.com/ridhwaans/environment.git $HOME/.local/share/environment
source $HOME/.local/share/environment/install.sh
```

wget
```bash
wget -qO- https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/main/boot.sh | bash
```

curl
```bash
curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/main/boot.sh | bash
```

docker
```bash
docker run -w /root -it --rm debian sh -uelic '
  apt update -y
  apt install -y --no-install-recommends ca-certificates curl git sudo zsh
  curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/main/user.sh | bash
  sudo -u vscode touch /home/vscode/.zshrc
  sudo -u vscode -i zsh -c "
    curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/main/boot.sh | bash
  " && sudo -u vscode -i zsh
'
```
