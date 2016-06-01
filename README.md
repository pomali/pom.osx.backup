# OS X Backup script
Simple backup script configurable with configuration files.

Backs up files from `includes.conf`, and saves brew, brew-cask, gem, pip, npm, apm package lists, list of /Applications and ~/Applications, and `/etc/hosts` file.

## Configuration
Script uses rsync to backup files in `includes.conf`, my recommendation is to use absolute paths so rsync would create whole structure inside backup folder. Lines starting with `#` and empty lines are ignored. 

In `excludes.rsync` you can configure rsync exclusions (filters applied to all files) eg. exclude .Trashes folders. 

In `backup.conf` you can set any of variables 

 Variable | Meaning | Default 
 --- | --- | --- 
 SCRIPT_NAME | Name used for logging into syslog and backup folder name | `pom.osx.backup` 
 RSYNC | path and arguments to rsync | `/usr/bin/rsync -vaER --progress --exclude-from=$DIR/excludes.rsync --stats --delete ` 
 LOGGER | path to logger if you don't want logging leave empty | `"/usr/bin/logger -s -t $SCRIPT_NAME "` 
 BACKUP\_LOCATION | path to destination (folder/drive/ssh) of backup | `/Volumes/osx_backup`

## Usage 
`./backup.sh`


