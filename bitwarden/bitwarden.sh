#!/usr/bin/env bash

# A simple script to auto backup the bw-data directory.
# More useful information here: https://bitwarden.com/help/article/backup-on-premise/
# Note, paths may be different, bitwarden_rs uses /bw-data by default, more info here: https://github.com/dani-garcia/bitwarden_rs/wiki/Backing-up-your-vault

# Installing bitwarden_rs: https://github.com/dani-garcia/bitwarden_rs
#   Install docker and docker compose
#
#   docker pull bitwardenrs/server:latest
#   docker run -d --name bitwarden -v /bw-data/:/data/ -p 80:80 bitwardenrs/server:latest
#
#   Install the custom nginx configuration from here: https://github.com/jarulsamy/nginx-config

# Sample ls -la of /bw-data/

# -rw-r--r--  1 root root 318319887 May  7 14:34 bit.log (NOT BACKED UP)
# -rw-r--r--  1 root root    331776 May  7 13:53 db.sqlite3
# drwxr-xr-x  2 root root     12288 Apr 30 00:58 icon_cache (NOT BACKED UP)
# -rw-------  1 root root      1190 Mar 10 23:12 rsa_key.der
# -rw-------  1 root root      1675 Mar 10 23:12 rsa_key.pem
# -rw-r--r--  1 root root       270 Mar 10 23:12 rsa_key.pub.der

# Setup for this script #

# Everything is run on the HOST of the docker instance.
# Install rclone and sqlite3
# Create a new remote, detailed instructions here: https://rclone.org/drive/
# Adjust the following parameters as neeeded.

# Helpful sets
set -e

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BW_DIR="/bw-data"
BACKUP_DIR="$BW_DIR/db_backup"

REMOTE_DEST="josh_gdrive:Backups/Bitwarden/$TIMESTAMP"
TARBALL="/tmp/bw-data_$TIMESTAMP.tar.gz"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Ensure tarball doesn't exist
rm -rf "$TARBALL"
# Create destination
mkdir -p "$BACKUP_DIR"
# Dump sqlite db
sqlite3 "$BW_DIR/db.sqlite3" ".backup '/$BACKUP_DIR/backup.sqlite3'"
# Compress whole dir, excluding static files
tar -zcvf "$TARBALL" --exclude="*.png" --exclude="*.miss" --exclude="*.log" -C "$(dirname "$BW_DIR")" "$(basename "$BW_DIR")"

# Copy to remote
echo "Copying to gdrive"
rclone copy "$TARBALL" "$REMOTE_DEST/"
echo "Done copying"

# Delete tarball
rm -rf "$BACKUP_DIR" "$TARBALL"

set +e
