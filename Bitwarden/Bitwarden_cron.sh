#!/bin/bash

# Kill on error
set -e

CURRENTDATE=$(date + "%Y-%m-%d_%H-%M-%S")
DATA_DIR=/bw-data
BACKUP_DIR="$DATA_DIR/db_backup"
BACKUP_FILENAME="backup.sqlite3"
TARBALL="/tmp/bw-data_$CURRENTDATE.tar.gz"
REMOTE_DEST="josh_gdrive:Backups/Bitwarden"

# Ensure tarball doesn't exist already.
rm -rf $TARBALL
# Create output dir for backup db.
mkdir -p $BACKUP_DIR
# Use sqlite3 to properly export the db.
sqlite3 /$DATA_DIR/db.sqlite3 ".backup '/$BACKUP_DIR/$BACKUP_FILENAME'"
# Create the tarball.
tar -zcvf $TARBALL $BACKUP_DIR
# Copy it to remote (gdrive).
rclone copy $TARBALL "$REMOTE_DEST/"
# Cleanup, remove leftover files.
rm -rf $BACKUP_DIR $TARBALL

set +e

