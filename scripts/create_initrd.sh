#!/bin/sh

set -e

mkdir rootfs

cd rootfs
mkdir bin sbin etc proc sys usr dev
mkdir usr/bin usr/sbin

cd ..

cp /build/busybox rootfs/bin/busybox

QEMU_USER="qemu-$ARCH"
APPLETS=$($QEMU_USER /build/busybox --list)

for cmd in $APPLETS; do
    ln -s /bin/busybox rootfs/bin/$cmd
done

cat > rootfs/init << 'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys

echo "Hello from initrd!"

mknod /dev/ttyS0 c 4 64
setsid sh -c 'exec sh </dev/ttyS0 >/dev/ttyS0 2>&1'
EOF
chmod +x rootfs/init

mknod -m 622 rootfs/dev/console c 5 1
mknod -m 666 rootfs/dev/null c 1 3

cd rootfs
find . | cpio -o -H newc | gzip > ../initrd.gz
cd ..

mv initrd.gz $BUILD_DIR

