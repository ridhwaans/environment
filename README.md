# environment
 https://github.com/ridhwaans/environment

git
```bash
git clone -b test https://github.com/ridhwaans/environment.git $HOME/.local/share/environment
source $HOME/.local/share/environment/install.sh
```

wget
```bash
wget -qO- https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/test/boot.sh | bash
```

curl
```bash
curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/test/boot.sh | bash
```

docker
```bash
docker run -w /root -it --rm debian sh -uelic '
  apt update -y
  apt install -y --no-install-recommends ca-certificates curl git sudo zsh
  curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/test/user.sh | bash
  TARGET_USERNAME=$(grep '^TARGET_USERNAME=' /tmp/.environment | cut -d '=' -f2-)
  sudo -u $TARGET_USERNAME touch /home/$TARGET_USERNAME/.zshrc
  sudo -u $TARGET_USERNAME -i zsh -c "
    curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/test/boot.sh | bash
  " && sudo -u $TARGET_USERNAME -i zsh
'

```
