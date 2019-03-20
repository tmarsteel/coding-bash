#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "> setting up ~/.bashrc"
echo "" >> $HOME/.bashrc
echo "source $DIR/.bashrc" >> $HOME/.bashrc

echo "> applying git aliases"
"$DIR/apply-git-aliases.sh"

echo "Done. Restart the shell."
