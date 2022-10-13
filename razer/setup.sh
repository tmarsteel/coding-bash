#!/bin/bash

SELFDIR="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

echo "Setting up openrazer"
set -x
sudo add-apt-repository ppa:openrazer/stable
sudo apt-get update
sudo apt-get install openrazer-meta
sudo gpasswd -a "$USER" plugdev
set +x

echo "Setting up the keyboard config script"
echo "* * * * * DISPLAY=:1 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$UID/bus \"$SELFDIR/keyboard.py\" 1 &>> /dev/null" | "$SELFDIR/../append-to-crontab.sh"
