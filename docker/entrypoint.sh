set -e

CONFIG_FILE=/etc/cnosdb/cnosdb.conf

exec "cnosdb run --cpu 4 --memory 32 --config ${CONFIG_FILE}"
