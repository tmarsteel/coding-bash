#!/bin/bash

newBranchName="$1"
SELFDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}" )")"

set -e

if [[ "$(git ls-files -u)" != "" ]]
then
	>&2 echo -e "\e[1;31mYou have unresolved conflicts in your wokring directory.\e[0m"
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

echo -e "\e[2;96m> git checkout $defaultBranch\e[0m"
git checkout "$defaultBranch"

echo -e "\e[2;96m> git fetch --prune origin\e[0m"
git fetch --prune origin

echo -e "\e[2;96m> git pull\e[0m"
git pull

echo -e "\e[2;96m> git prune\e[0m"
git prune

echo -e "\e[2;96m> delete merged local branches\e[0m"
git branch --merged HEAD | grep -v "$defaultBranch" | sed -E 's/^\s*(.+?)\s*$/\1/' | xargs --no-run-if-empty git branch --delete

echo -e "\e[2;96m> git gc\e[0m"
git gc

if [[ "$newBranchName" != "" ]]
then
	set +e
	git ls-remote --exit-code --heads origin "$newBranchName"
	if [[ "$?" == "0" ]]
	then
	  # there already is a remote branch, checkt that one out
	  echo -e "\e[2;96m> git checkout -b $newBranchName origin/$newBranchName\e[0m"
		git checkout -b "$newBranchName" "origin/$newBranchName"
	else
	  echo -e "\e[2;96m> git checkout -b $newBranchName\e[0m"
		git checkout -b "$newBranchName"
	fi
fi

if [[ "$workingDirDirty" == "1" ]]
then
  echo -e "\e[2;96m> git stash pop\e[0m"
	git stash pop
fi
