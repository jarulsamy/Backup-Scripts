# Bitwarden

A script to automatically dump the bitwarden DB and upload it to Google drive.

More useful information [here](https://bitwarden.com/help/article/backup-on-premise/).

Note, paths may be different, bitwarden_rs uses `/bw-data` by default, more info [here](https://github.com/dani-garcia/bitwarden_rs/wiki/Backing-up-your-vault).

>Everything is run on the **HOST** of the docker instance.

## Installation

1.  Install rclone and sqlite3

```bash
$ sudo apt update
$ sudo apt install rclone sqlite3
```

2.  Create a new rclone remote, detailed instructions [here](https://rclone.org/drive/).

3.  Adjust the variables in the script as neeeded.

### Crontab

Edit the root crontab:

```bash
$ sudo crontab -e
```

Add an entry like this (Runs as 12 AM daily)

    0 0 * * * <PATH_TO_Bitwarden.sh> 2>&1 1>/dev/null # Redirect ALL output to /dev/null
