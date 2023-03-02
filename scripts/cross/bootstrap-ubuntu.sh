#!/bin/sh
set -o errexit

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update
apt-get install --assume-yes apt-utils
apt-get install -y wget
apt-get install -y git
apt-get install -y unzip
apt-get install -y gnupg

cat <<-EOF > /etc/apt/sources.list.d/llvm.list
deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-12 main
deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-12 main
EOF

wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key > apt-key.txt
apt-key add apt-key.txt
apt-get install -y libclang1-12
apt-get install -y llvm-12


dpkg --add-architecture arm64
apt-get update
apt-get install -y libssl-dev libssl-dev:arm64 zlib1g-dev zlib1g-dev:arm64
