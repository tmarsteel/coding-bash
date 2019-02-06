#!/bin/bash

newBranchName="$1"

set -e

# stash changes

repositoryRootDir=`git rev-parse --show-toplevel`

cd "$repositoryRootDir"

message=
if [ "$newBranchName" != "" ]
then
	message="before starting branch $newBranchName"
fi

set -x

git stash push --include-untracked --message "$message"

# cleanup & checkout

git checkout master
git remote prune origin
git prune
git gc
git pull

if [ "$newBranchName" != "" ]
then
	git checkout -b "$newBranchName"
fi
