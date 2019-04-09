#!/bin/bash
DIR="$( realpath "$(dirname "${BASH_SOURCE[0]}" )")"

git config --global alias.ready "!$DIR/git-ready.sh"
git config --global alias.fuckit "!git add -A && git commit --amend --no-edit && git push --force-with-lease"
git config --global alias.qc "!$DIR/git-qc.sh"
git config --global alias.default-branch "!$DIR/git-default-branch.sh"
