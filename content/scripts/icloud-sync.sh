#!/bin/bash
source /home/andrew/.bashrc
# Set variables
DEST="/mnt/Data/Photos/iCloud"
UNAME="andrew.ge.wu@outlook.com"
UPWD="8a628198Ios"

# Sync all libraries
/home/andrew/.local/bin/icloudpd  --username "$UNAME" --password "$UPWD" --list-libraries | xargs -L 1 /home/andrew/.local/bin/icloudpd --username "$UNAME" --password "$UPWD" --directory "$DEST" --auto-delete --until-found 100 --library 
