#!/bin/bash

git diff --exit-code

if [ "$?" -ne "0" ]
then
	echo "Your working directoy must be clean."
	exit 129
fi

set -e

git checkout master
git remote prune origin
git prune
git gc
git pull
