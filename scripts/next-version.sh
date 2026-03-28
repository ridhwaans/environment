#!/usr/bin/env bash

set -euo pipefail

release_type="${1:-patch}"
year="$(date -u +%Y)"
latest_for_year="$(git tag --list "${year}.*" --sort=-v:refname | head -n 1)"

case "$release_type" in
  major)
    if [ -z "$latest_for_year" ]; then
      echo "${year}.1"
      exit 0
    fi

    train="$(echo "$latest_for_year" | cut -d. -f2)"
    echo "${year}.$((train + 1))"
    ;;
  patch)
    if [ -z "$latest_for_year" ]; then
      echo "${year}.1"
      exit 0
    fi

    dot_count="$(awk -F. '{print NF-1}' <<< "$latest_for_year")"
    if [ "$dot_count" -eq 1 ]; then
      echo "${latest_for_year}.1"
      exit 0
    fi

    train="$(echo "$latest_for_year" | cut -d. -f2)"
    patch="$(echo "$latest_for_year" | cut -d. -f3)"
    echo "${year}.${train}.$((patch + 1))"
    ;;
  *)
    echo "Unsupported release type: $release_type" >&2
    exit 1
    ;;
esac
