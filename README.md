# environment

[https://github.com/ridhwaans/environment/tree/main](https://github.com/ridhwaans/environment/tree/main)

git

```bash
git clone -b main https://github.com/ridhwaans/environment.git $HOME/Source/environment
bash $HOME/Source/environment/install.sh
```

skip appearance defaults

```bash
bash $HOME/Source/environment/install.sh --no-appearance-defaults
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
  export ENVIRONMENT_START_SECONDS=$(date +%s) &&
  apt update -y &&
  apt install -y --no-install-recommends ca-certificates curl git sudo zsh &&
  curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/main/user.sh | bash &&
  TARGET_USERNAME=$(grep "^TARGET_USERNAME=" /tmp/.environment | cut -d"=" -f2-) &&
  sudo -u "$TARGET_USERNAME" env ENVIRONMENT_START_SECONDS="$ENVIRONMENT_START_SECONDS" bash -c "curl -fsSL https://raw.githubusercontent.com/ridhwaans/environment/refs/heads/main/boot.sh -o /tmp/boot.sh && bash /tmp/boot.sh --no-appearance-defaults && rm -f /tmp/boot.sh" &&
  exec sudo -u "$TARGET_USERNAME" env \
  HOME="/home/$TARGET_USERNAME" \
  ZDOTDIR="/home/$TARGET_USERNAME/.config/zsh" \
  bash -c "cd \$HOME && exec zsh -l"
'
```

#### downstream

[https://github.com/ridhwaans/dotfiles/tree/main](https://github.com/ridhwaans/dotfiles/tree/main)
[https://github.com/ridhwaans/appearance/tree/main](https://github.com/ridhwaans/appearance/tree/main)

