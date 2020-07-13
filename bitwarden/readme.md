# Bitwarden

A script to automatically dump the bitwarden DB and upload it to Google drive.

More useful information [here](https://bitwarden.com/help/article/backup-on-premise/).

Note, paths may be different, bitwarden_rs uses `/bw-data` by default, more info [here](https://github.com/dani-garcia/bitwarden_rs/wiki/Backing-up-your-vault).

Everything is run on the **HOST** of the docker instance.
<!-- ```
#!/usr/bin/env bash

# A simple script to auto backup the bw-data directory.

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
``` -->

## Installation

1. Install rclone and sqlite3

```
$ sudo apt update
$ sudo apt install rclone sqlite3
```

2. Create a new rclone remote, detailed instructions [here](https://rclone.org/drive/).

3. Adjust the variables in the script as neeeded.

### Crontab

Edit the root crontab:
```
$ sudo crontab -e
```

Add an entry like this (Runs as 12 AM daily)
```
0 0 * * * <PATH_TO_Bitwarden.sh> 2>&1 1>/dev/null # Redirect ALL output to /dev/null
```
