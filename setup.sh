#!/bin/bash
SELFDIR="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

echo "> setting up ~/.bashrc"
echo "" >> $HOME/.bashrc
echo "source $SELFDIR/.bashrc" >> $HOME/.bashrc

echo "> setting up ~/.nanorc"
ln -s "$SELFDIR/.nanorc" "$HOME/.nanorc"

echo "> applying git aliases"
"$SELFDIR/apply-git-aliases.sh"

echo "Done. Restart the shell."
