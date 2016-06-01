#!/bin/bash

# Inspirations
# https://www.davidwaring.net/projects/backup.html
# https://gist.github.com/tommeier/2128730
# https://www.haykranen.nl/2008/05/05/rsync/
# http://www.macworld.com/article/2855735/the-paranoid-persons-guide-to-a-complete-mac-backup.html

#diskutil list
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE=$DIR'/backup.conf.sh'

SCRIPT_NAME="pom.osx.backup"
RSYNC="/usr/bin/rsync -vaR --progress --exclude-from=$DIR/excludes.rsync --stats --delete "
LOGGER="/usr/bin/logger -s -t $SCRIPT_NAME "
# Load config file
if [ ! -f $CONFIG_FILE ]; then
    echo "Missing $CONFIG_FILE config file"
    exit 1
fi
source $CONFIG_FILE

DEST=$BACKUP_LOCATION"/$SCRIPT_NAME.data/"

if [ -z $LOGGER ];then
    LOGGER=echo
fi;

$LOGGER "Backup start; Location:'$DEST'"

if [ ! -d $DEST ]; then
    echo "Creating $DEST"
    mkdir $DEST;
fi

$RSYNC $(sed -e 's/^#.*$//' -e '/^$/d' includes.conf | sort)  $DEST
# copy some special symlinked files
$RSYNC -L "/etc/hosts"  $DEST

brew list > $DEST/brew_list.txt
brew cask list > $DEST/brew_cask_list.txt
gem list > $DEST/gem_list.txt
pip freeze > $DEST/pip_freeze.txt
npm list -g > $DEST/npm_list.txt
apm list -b > $DEST/apm_list.txt
ls ~/Applications > $DEST/user_Applications.txt
ls /Applications > $DEST/global_Applications.txt


#/usr/bin/caffeinate -s $RSYNC -aH /Users user@rsync.net: >> /var/log/backup.log
$LOGGER "Backup end"
