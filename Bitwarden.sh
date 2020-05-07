#!/bin/bash

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

# -rw-r--r--  1 root root 318319887 May  7 14:34 bit.log (NOT BACKUPED UP)
# -rw-r--r--  1 root root    331776 May  7 13:53 db.sqlite3
# drwxr-xr-x  2 root root     12288 Apr 30 00:58 icon_cache
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

# Date format: YYYY-MM-DD_HH-MM-SS
CURRENTDATE=$(date +"%Y-%m-%d_%H-%M-%S")
DATA_DIR=/bw-data
BACKUP_DIR="$DATA_DIR/db_backup"
BACKUP_FILENAME="backup.sqlite3"
TARBALL="/tmp/bw-data_$CURRENTDATE.tar.gz"

REMOTE_DEST="josh_gdrive:Backups/Bitwarden"

USER=$(whoami)
GROUP=$(id -gn)

# Ensure script is not run as root
if ! [ "$EUID" -ne 0 ]; then
    echo "DO NOT RUN AS ROOT!"
    exit 1
fi

# Parse CLI arguments.
while test $# -gt 0; do
    case "$1" in
    -h | --help)
        echo "$package - Create a tarball of bw-data and upload to gdrive."
        echo " "
        echo "$package [options] application [arguments]"
        echo " "
        echo "options:"
        echo "-h, --help                show brief help"
        echo "-d, --dry-run             Dry run, don't actually create an archive."
        exit 0
        ;;
    -d | --dry-run)
        shift
        echo "Dry run enabled!"
        echo "DATA_DIR: $DATA_DIR"
        echo "BACKUP_DIR: $BACKUP_DIR"
        echo "BACKUP_FILENAME: $BACKUP_FILENAME"
        echo "TARBALL: $TARBALL"
        echo "REMOTE_DEST: $REMOTE_DEST"
        echo "USER: $USER"
        echo "GROUP: $GROUP"
        exit 0
        ;;
    *)
        break
        ;;
    esac
done

# Ensure tarball doesn't exist already.
sudo rm -rf $TARBALL
# Create output dir for backup db.
sudo mkdir -p $BACKUP_DIR
# Use sqlite3 to properly export the db.
sudo sqlite3 /$DATA_DIR/db.sqlite3 ".backup '/$BACKUP_DIR/$BACKUP_FILENAME'"
# Create the tarball.
sudo tar -zcvf $TARBALL $BACKUP_DIR
# Change the user to me.
sudo chown $USER:$GROUP $TARBALL
# Copy it to remote (gdrive).
rclone copy $TARBALL "$REMOTE_DEST/"
# Cleanup, remove leftover files.
sudo rm -rf $BACKUP_DIR $TARBALL

set +e
