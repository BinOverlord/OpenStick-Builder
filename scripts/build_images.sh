#!/bin/sh -e

CHROOT=${CHROOT=$(pwd)/rootfs}

#package rootfs
rm -rf rootfs.raw boot.raw staging
mkdir -p files staging/boot staging/root

# populate the filesystems from directories (mkfs -d) instead of loop
# mounting the images, so no loop devices are needed (e.g. in containers)

# create boot
tar xf rootfs.tgz -C staging/boot ./boot --exclude='./boot/linux.efi' --strip-components=2
truncate -s 67108864 boot.raw
mkfs.ext2 -d staging/boot boot.raw

# create root img
tar xpf rootfs.tgz -C staging/root --exclude='./boot/*' --exclude='./root/*' --exclude='./dev/*'

# install gt
cp -a dist/* staging/root

truncate -s 1610612736 rootfs.raw
mkfs.ext4 -d staging/root rootfs.raw

rm -rf staging

# create sparse android images
img2simg rootfs.raw files/rootfs.bin
img2simg boot.raw files/boot.bin
