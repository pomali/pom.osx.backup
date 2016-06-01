#!/bin/bash
set -e 

# Inspirations
# https://www.davidwaring.net/projects/backup.html
# https://gist.github.com/tommeier/2128730
# https://www.haykranen.nl/2008/05/05/rsync/
# http://www.macworld.com/article/2855735/the-paranoid-persons-guide-to-a-complete-mac-backup.html

#diskutil list
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE=$DIR'/backup.conf.sh'

SCRIPT_NAME="pom.osx.backup"
RSYNC="/usr/bin/rsync -ivrlt -R --exclude-from=$DIR/excludes.rsync --delete "
LOGGER="/usr/bin/logger -s -t $SCRIPT_NAME "
# Load config file
if [ ! -f $CONFIG_FILE ]; then
    echo "Missing $CONFIG_FILE config file"
    exit 1
fi
source $CONFIG_FILE

DEST=$BACKUP_LOCATION"/$SCRIPT_NAME.data/"

if [ -z "$LOGGER" ];then
    LOGGER=echo
fi;

$LOGGER "Backup start; Location:'$DEST'"


if [ ! -d $DEST ]; then
    echo "Creating $DEST"
    mkdir $DEST;
fi


#### BACKUP & ENCRYPT SSH FOLDER ####
echo "Backing up ~/.ssh folder, please choose password"
SSH_TAR_FILENAME="ssh.tar.aes256"
tar -cz -C ~/ .ssh | openssl enc -aes256 -out $DEST/$SSH_TAR_FILENAME
#extract using script in extract_ssh.sh
echo "openssl enc -aes256 -in $SSH_TAR_FILENAME -salt -d | tar -x  " > $DEST/extract_ssh.sh

##### BACKUP FILES #####
echo "Backing up Keychains please authorize sudo"
sudo $RSYNC /Users/pom/Library/Keychains $DEST

echo "Backing up included files"
$RSYNC $(sed -e 's/^#.*$//' -e '/^$/d' includes.conf | sort)  $DEST

# copy some special symlinked files
echo "Backing up /etc/hosts"
$RSYNC -L "/etc/hosts"  $DEST

##### BACKUP PACKAGES IN PACKAGE MANAGERS #####
echo "Backing up brew packages"
brew list > $DEST/brew_list.txt
brew cask list > $DEST/brew_cask_list.txt
echo "Backing up gem packages"
gem list > $DEST/gem_list.txt
echo "Backing up pip packages"
pip freeze > $DEST/pip_freeze.txt
echo "Backing up npm packages"
npm list -g > $DEST/npm_list.txt
echo "Backing up apm packages"
apm list -b > $DEST/apm_list.txt
echo "Backing up Applications names"
ls ~/Applications > $DEST/user_Applications.txt
ls /Applications > $DEST/global_Applications.txt

#/usr/bin/caffeinate -s $RSYNC -aH /Users user@rsync.net: >> /var/log/backup.log
$LOGGER "Backup end"
