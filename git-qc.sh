#!/bin/bash

set -ex

gitRootDir=$(git rev-parse --show-toplevel 2> /dev/null)
currentBranchName=$(git name-rev --no-undefined --name-only HEAD)

prefix=
if [[ "$currentBranchName" =~ ^[A-Za-z0-9]{2,}-[0-9]+$ ]]
then
	prefix="$currentBranchName: "
fi

message=$@

git add "$gitRootDir"
git commit -m "$prefix$message"
