#!/bin/sh -e

apt update
apt install -y \
    android-sdk-libsparse-utils \
    autoconf \
    automake \
    binfmt-support \
    cmake \
    debian-archive-keyring \
    debootstrap \
    device-tree-compiler \
    fdisk \
    g++-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu \
    gcc-arm-none-eabi \
    libtool \
    make \
    pkg-config \
    python3-cryptography \
    python3-pyasn1-modules \
    python3-pycryptodome \
    qemu-user-static \
    unzip \
    wget 

# make sure aarch64 binaries can run inside the rootfs chroot; package
# postinst scripts may not register qemu with binfmt_misc in containers
# without systemd (e.g. self-hosted runners)
BINFMT=/proc/sys/fs/binfmt_misc
if ! grep -qs '^enabled' ${BINFMT}/qemu-aarch64; then
    [ -e ${BINFMT}/register ] || mount -t binfmt_misc binfmt_misc ${BINFMT} || {
        echo "Cannot mount binfmt_misc: run the container privileged or register qemu-aarch64 on the host" >&2
        exit 1
    }
    if [ -e ${BINFMT}/qemu-aarch64 ]; then
        echo 1 > ${BINFMT}/qemu-aarch64
    else
        printf '%s\n' ':qemu-aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-aarch64-static:F' \
            > ${BINFMT}/register
    fi
fi
grep -q '^enabled' ${BINFMT}/qemu-aarch64
