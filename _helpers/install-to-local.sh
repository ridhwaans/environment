install_to_local() {
  if [ ! -z "${sources}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a sources <<< "$SOURCES"
        for source in "${sources[@]}"; do
          cd $source && sudo $( [ $source = $DOTFILES_SOURCE ] && echo "-u $USERNAME" ) ./install.sh
        done
    IFS=$OLDIFS
  fi
}
