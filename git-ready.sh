#!/bin/bash

newBranchName="$1"

message=
if [ "$newBranchName" != "" ]
then
	message="before starting branch $newBranchName"
fi

set -ex

git stash push --include-untracked --message "$message"

git checkout master
git remote prune origin
git prune
git gc
git pull

if [ "$newBranchName" != "" ]
then
	git checkout -b "$newBranchName"
fi
