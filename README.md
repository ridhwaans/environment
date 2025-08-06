# environment
 https://github.com/ridhwaans/environment/tree/main

git
```bash
git clone -b main https://github.com/ridhwaans/environment.git $HOME/Source/environment
bash $HOME/Source/environment/install.sh
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
docker run -w /root -it --rm debian bash -c '
  apt update -y &&
  apt install -y --no-install-recommends ca-certificates curl git sudo zsh &&
  curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/main/user.sh | bash &&
  TARGET_USERNAME=$(grep "^TARGET_USERNAME=" /tmp/.environment | cut -d"=" -f2-) &&
  sudo -u "$TARGET_USERNAME" bash -c "curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/main/boot.sh | bash" &&
  exec sudo -u "$TARGET_USERNAME" env \
  HOME="/home/$TARGET_USERNAME" \
  ZDOTDIR="/home/$TARGET_USERNAME/.config/zsh" \
  bash -c "cd \$HOME && exec zsh -l"
'
```
