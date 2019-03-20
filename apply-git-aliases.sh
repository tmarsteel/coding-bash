#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
git config alias.ready "!$DIR/git-ready.sh"
git config alias.fuckit "!git add -A && git commit --amend --no-edit && git push --force-with-lease"