#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

# Mac OS packages
install_mac_packages() {
  run_brew_command_as_target_user install dockutil

  apps=(
      beekeeper-studio
      docker
      discord
      dropbox
      figma
      iterm2@nightly
      kap
      mounty
      notion
      postman
      steam
      visual-studio-code
  )

  if [ ! -d "/Applications/Google Chrome.app" ]; then
      apps+=(google-chrome)
  fi

  if [ ! -d "/Applications/Slack.app" ]; then
      apps+=(slack)
  fi

  if [ ! -d "/Applications/zoom.us.app" ]; then
      apps+=(zoom)
  fi

  run_brew_command_as_target_user install --cask "${apps[@]}"

  # Remove outdated versions from the cellar
  run_brew_command_as_target_user cleanup

	# Set Dock items
	OLDIFS=$IFS
	IFS=''

	apps=(
		'Google Chrome'
		'Visual Studio Code'
		iTerm
		'Beekeeper Studio'
		Postman
		Notion
		Slack
		Figma
		zoom.us
		Docker
		'System Settings'
	)

	dockutil --no-restart --remove all $HOME
	for app in "${apps[@]}"
	do
		echo "Keeping $app in Dock"
		dockutil --no-restart --add /Applications/$app.app $HOME
	done
	killall Dock

	# restore $IFS
	IFS=$OLDIFS
}


# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "mac")
        install_mac_packages
        ;;
esac
