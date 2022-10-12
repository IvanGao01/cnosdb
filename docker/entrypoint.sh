#!/bin/bash

set -e

CONFIG_FILE=/etc/cnosdb/cnosdb.conf

exec "/usr/bin/cnosdb run --cpu 4 --memory 64 --config ${CONFIG_FILE}"
