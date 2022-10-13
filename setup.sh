#!/bin/bash
SELFDIR="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

echo "> Installing Software"
set -x
sudo apt-get install jq
set +x

echo "> setting up ~/.bashrc"
echo "" >> $HOME/.bashrc
echo "source $SELFDIR/.bashrc" >> $HOME/.bashrc

echo "> setting up ~/.nanorc"
ln -s "$SELFDIR/.nanorc" "$HOME/.nanorc"

echo "> applying git aliases"
"$SELFDIR/apply-git-aliases.sh"

"$SELFDIR/razer/setup.sh"

echo "Done. Restart the shell."
