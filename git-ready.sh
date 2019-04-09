#!/bin/bash

newBranchName="$1"
SELFDIR="$( realpath "$(dirname "${BASH_SOURCE[0]}" )")"

set -e

# stash changes

repositoryRootDir=`git rev-parse --show-toplevel`
workingDirDirty=0
if [[ $(git diff --stat) != '' ]]
then
	workingDirDirty=1
fi

cd "$repositoryRootDir"

if [[ "$workingDirDirty" == "1" ]]
then
	message=
	if [ "$newBranchName" != "" ]
	then
		message="before starting branch $newBranchName"
	fi

	git stash push --include-untracked --message "$message"
fi

defaultBranch=`$SELFDIR/git-default-branch.sh`

# cleanup & checkout

echo "> git checkout \"$defaultBranch\""
git checkout "$defaultBranch"

echo "> git fetch --prune origin"
git fetch --prune origin

echo "> git pull"
git pull

echo "> git prune"
git prune

echo "> delete merged local branches"
git branch --merged HEAD | grep -v master | sed -E 's/^\s*(.+?)\s*$/\1/' | xargs --no-run-if-empty git branch --delete

echo "> git gc"
git gc

if [ "$newBranchName" != "" ]
then
	git checkout -b "$newBranchName"
fi

if [ "$workingDirDirty" == "1" ]
then
	git stash pop
fi
