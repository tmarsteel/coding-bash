#!/bin/bash

set -e

gitRootDir=$(git rev-parse --show-toplevel 2> /dev/null)
currentBranchName=$(git name-rev --no-undefined --name-only HEAD)

prefix=
if [[ "$currentBranchName" =~ ^[A-Za-z0-9]{2,}-[0-9]+$ ]]
then
	prefix="$currentBranchName: "
fi

message=$@

echo "> git add $gitRootDir"
git add "$gitRootDir"

echo "> git commit -m $prefix$message"
git commit -m "$prefix$message"

set +e

upstream=$(git rev-parse @{u} 2> /dev/null)
if [[ "$?" != 0 ]]
then
	echo "> git push --set-upstream origin $currentBranchName"
	git push --set-upstream origin "$currentBranchName"
else
  echo "> git push --force-with-lease"
	git push --force-with-lease
fi
