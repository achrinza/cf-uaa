#/bin/sh
# SPDX-FileCopyrightText: Copyright 2024 Rifa Achrinza
# SPDX-License-Identifier: Apache-2.0
set -o pipefail
set -eu

VERSION="v77.9.0"
NAME="cf-uaa"

parse_opts() {
  OPTIND=1
  while getopts ':V:n:' opt; do
    case "$opt" in
      \?)
        printf "Invalid option: -%s" "$OPTARG" 1>&2
	exit 2
	;;
      V)
        VERSION="$OPTARG"
        ;;
      n)
        NAME="$OPTARG"
        ;;
    esac
  done
}

create_image() {
  vendorUAA=vendor/uaa
  git submodule update --init --recursive "$vendorUAA"
  git -C "$vendorUAA" clean -dfx
  git -C "$vendorUAA" checkout "$VERSION"
  cp project.toml "$vendorUAA"
  if [ "$(command -v podman)" != '' ]; then
    export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
    systemctl --user start podman
    pack build --docker-host=inherit --path="$vendorUAA" "${NAME}:$(printf '%s' "$VERSION" | cut -c2-)"
  else
    pack build --path="$vendorUAA" "${NAME}:$(printf '%s' "$VERSION" | cut -c2-)"
  fi
}

parse_opts $@
create_image
