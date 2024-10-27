#!/bin/bash
SELFDIR="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

echo "> Installing Software"
set -x
sudo apt-get install jq cowsay fortune
set +x

echo "> setting up ~/.bashrc"
echo "" >> $HOME/.bashrc
echo "source $SELFDIR/.bashrc" >> $HOME/.bashrc

echo "> setting up ~/.nanorc"
ln -s "$SELFDIR/.nanorc" "$HOME/.nanorc"

echo "> applying git aliases"
"$SELFDIR/apply-git-aliases.sh"

"$SELFDIR/razer/setup.sh"

echo "> setting up custom panel date format"
"$SELFDIR/install-gnome-shell-extension.sh" "https://extensions.gnome.org/extension-data/panel-date-formatatareao.es.v8.shell-extension.zip"
echo "* * * * * DISPLAY=:1 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$UID/bus \"$SELFDIR/set-panel-date-format.sh\"" | "$SELFDIR/append-to-crontab.sh"
dconf write /org/gnome/desktop/interface/clock-show-seconds true

echo "Done. Restart the shell."
