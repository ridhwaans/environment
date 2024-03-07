install_to_local() {
  # Run install.sh as sudo
  cd $SOURCE && sudo ./install.sh

  if [ ! -z "${SOURCE_ADDITIONAL}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a source_additional <<< "$SOURCE_ADDITIONAL"
        for source in "${source_additional[@]}"; do
          cd "${source}" && sudo ./install.sh
        done
    IFS=$OLDIFS
  fi
}
