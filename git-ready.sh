#!/bin/bash

newBranchName="$1"
SELFDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}" )")"

set -e

if [[ "$(git ls-files -u)" != "" ]]
then
	>&2 printf '\033[1;31mYou have unresolved conflicts in your wokring directory.\033[0m\n'
	exit 127
fi

# stash changes

repositoryRootDir=`git rev-parse --show-toplevel`

cd "$repositoryRootDir"

workingDirDirty=0
if [[ "$(git diff --stat)" != '' ]]
then
	workingDirDirty=1
fi

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

printf '\033[2;96m> git checkout $defaultBranch\033[0m\n'
git checkout "$defaultBranch"

printf '\033[2;96m> git fetch --prune origin\033[0m\n'
git fetch --prune origin

printf '\033[2;96m> git pull\033[0m\n'
git pull

printf '\033[2;96m> git prune\033[0m\n'
git prune

printf '\033[2;96m> delete merged local branches\033[0m\n'
git branch --merged HEAD | grep -v "$defaultBranch" | sed -E 's/^\s*(.+?)\s*$/\1/' | xargs --no-run-if-empty git branch --delete

if [[ "$(($RANDOM % 4))" == "0" ]]
then
	printf '\033[2;96m> git gc\033[0m\n'
	git gc
fi

if [[ "$newBranchName" != "" ]]
then
	set +e
	git ls-remote --exit-code --heads origin "$newBranchName"
	if [[ "$?" == "0" ]]
	then
	  # there already is a remote branch, checkt that one out
	  printf '\033[2;96m> git checkout -b $newBranchName origin/$newBranchName\033[0m\n'
		git checkout -b "$newBranchName" "origin/$newBranchName"
	else
	  printf '\033[2;96m> git checkout -b $newBranchName\033[0m\n'
		git checkout -b "$newBranchName"
	fi
fi

if [[ "$workingDirDirty" == "1" ]]
then
  printf '\033[2;96m> git stash pop\033[0m\n'
	git stash pop
fi
