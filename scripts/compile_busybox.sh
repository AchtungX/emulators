#!/bin/sh

set -e


if [ -z "$1" ]; then
  echo "Usage: $0 <busybox-tarball-url>"
  exit 1
fi

TARBALL_URL="$1"
TARBALL_NAME=$(basename "$TARBALL_URL")
BUSYBOX_DIR="${TARBALL_NAME%.tar.*}"

wget "$TARBALL_URL"
tar -xf "$TARBALL_NAME"
rm "$TARBALL_NAME"

cd "$BUSYBOX_DIR"

make defconfig

# Add the CONFIG_STATIC option to busybox's config file
sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config

make -j"$(nproc)"

cp busybox "$BUILD_DIR"
