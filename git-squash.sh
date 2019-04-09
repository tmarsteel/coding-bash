#!/bin/bash

SELFDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}" )")"

set -e

# causes an abort if working dir is dirty
"$SELFDIR/git-dirty.sh"

echo "> git fetch"
git fetch

defaultBranch="$("$SELFDIR/git-default-branch.sh")"
currentBranch="$(git name-rev --name-only HEAD)"

if [[ "$defaultBranch" == "$currentBranch" ]]
then
	>&2 echo "Already on the default branch $defaultBranch. Cannot auto-squash."
fi

echo ">git reset --soft \"$defaultBranch@{upstream}^1\""
git rebase "$defaultBranch@{upstream}"
