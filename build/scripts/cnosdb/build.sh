#!/bin/bash

set -e

ARCH=
OS=
PKG_HOME=/cnosdb/build/release/cnosdb
VERSION=$(grep 'workspace.package' /cnosdb/Cargo.toml -A 3 | grep 'version =' | sed 's/.*"\(.*\)"/\1/')
LOG_DIR=/var/log/cnosdb
DATA_DIR=/var/lib/cnosdb

NAME=cnosdb
USER=cnosdb
GROUP=cnosdb
DESCRIPTION=
LICENSE="AGPL-3.0"


# Create layout for packaging under $PKG_HOME.


rm -rf "${PKG_HOME}"
mkdir -p "${PKG_HOME}/usr/bin" \
         "${PKG_HOME}/var/log/cnosdb" \
         "${PKG_HOME}/var/lib/cnosdb" \
         "${PKG_HOME}/usr/lib/cnosdb/scripts" \
         "${PKG_HOME}/etc/cnosdb" \
         "${PKG_HOME}/etc/logrotate.d"
chmod -R 0755 ${PKG_HOME}

# Copy service scripts.
cp /cnosdb/build/scripts/cnosdb/init.sh "${PKG_HOME}/usr/lib/cnosdb/scripts/init.sh"
chmod 0644 "${PKG_HOME}/usr/lib/cnosdb/scripts/init.sh"
cp /cnosdb/build/scripts/cnosdb/cnosdb.service "${PKG_HOME}/usr/lib/cnosdb/scripts/cnosdb.service"
chmod 0644 "${PKG_HOME}/usr/lib/cnosdb/scripts/cnosdb.service"
cp /cnosdb/build/scripts/cnosdb/cnosdb-systemd-start.sh "${PKG_HOME}/usr/lib/cnosdb/scripts/cnosdb-systemd-start.sh"
chmod 0755 "${PKG_HOME}/usr/lib/cnosdb/scripts/cnosdb-systemd-start.sh"

# Copy logrotate file

cp /cnosdb/build/scripts/cnosdb/logrotate "${PKG_HOME}/etc/logrotate.d/cnosdb"
chmod 0644 "${PKG_HOME}/etc/logrotate.d/cnosdb"

# Copy sample config.
cp /cnosdb/config/config.toml "${PKG_HOME}/etc/cnosdb/cnosdb.conf"
chmod 0644 "${PKG_HOME}/etc/cnosdb/cnosdb.conf"

cp /cnosdb/target/release/cnosdb "${PKG_HOME}/usr/bin/"
cp /cnosdb/target/release/cnosdb-cli "${PKG_HOME}/usr/bin/"

 PACKAGE_NAME=$(fpm -t deb \
 -C "${PKG_HOME}" \
 -n ${NAME} \
 -v ${VERSION} \
 --architecture amd64 \
 -s dir \
 --url "https://www.cnosdb.com/" \
 --before-install /cnosdb/build/scripts/cnosdb/before-install.sh \
 --after-install /cnosdb/build/scripts/cnosdb/after-install.sh \
 --after-remove /cnosdb/build/scripts/cnosdb/after-remove.sh \
 --directories ${LOG_DIR} \
 --directories ${DATA_DIR} \
 --rpm-attr 755,${USER},${GROUP}:${LOG_DIR} \
 --rpm-attr 755,${USER},cnosdb:${DATA_DIR} \
 --config-files /etc/logrotate.d/cnosdb \
 --config-files /etc/cnosdb/cnosdb.conf \
 --maintainer "CnosDB Team" \
 --vendor "CnosDB Tech (Beijing) Limited" \
 --license ${LICENSE} \
 --description "An Open Source Distributed Time Series Database with high performance, high compression ratio and high usability." \
 --iteration 1 | ruby -e 'puts (eval ARGF.read)[:path]')