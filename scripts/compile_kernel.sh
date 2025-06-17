#!/bin/sh
set -e

# --- Configuration ---
if [ -z "$1" ]; then
  echo "Usage: $0 <kernel-version> (e.g. 3.18.140)"
  exit 1
fi

KERNEL_VERSION="$1"
KERNEL_MAJOR=$(echo "$KERNEL_VERSION" | cut -d. -f1)
KERNEL_SRC="linux-$KERNEL_VERSION"
KERNEL_ARCHIVE="$KERNEL_SRC.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_MAJOR}.x/$KERNEL_ARCHIVE"


# --- Download & extract kernel ---
wget -c "$KERNEL_URL"
tar -xf "$KERNEL_ARCHIVE"
rm "$KERNEL_ARCHIVE"
cd "$KERNEL_SRC"

# --- Default config ---
make malta_defconfig

# --- Apply required config tweaks ---
make KCONFIG_CONFIG=.config silentoldconfig

set_config() {
    key="$1"
    val="$2"
    sed -i "/^# $key is not set/d" .config
    sed -i "/^$key=/d" .config
    echo "$key=$val" >> .config
}

set_config_str() {
    key="$1"
    val="$2"
    sed -i "/^$key=/d" .config
    echo "$key=\"$val\"" >> .config
}

# Endianes
set_config CONFIG_CPU_BIG_ENDIAN y

# Initramfs and root from RAM
set_config CONFIG_BLK_DEV_INITRD y
set_config CONFIG_BLK_DEV_RAM y
set_config CONFIG_DEVTMPFS y
set_config CONFIG_DEVTMPFS_MOUNT y
set_config CONFIG_TMPFS y

# Basic networking
set_config CONFIG_NET y
set_config CONFIG_INET y
set_config CONFIG_PCI y
set_config CONFIG_NETDEVICES y
set_config CONFIG_ETHERNET y

# Network driver
set_config CONFIG_PCNET32 y

# Recalculate final config
make olddefconfig

# --- Build the kernel ---
make -j"$(nproc)" vmlinux

cp vmlinux $BUILD_DIR
