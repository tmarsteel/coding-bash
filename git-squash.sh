#!/bin/bash

SELFDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}" )")"

PUSH=1
if [[ "$1" == "--no-push" ]]
then
	PUSH=0
	shift
fi

set -e

repositoryRootDir="$(git rev-parse --show-toplevel)"

# causes an abort if working dir is dirty
"$SELFDIR/git-dirty.sh"

echo "> git fetch"
git fetch

defaultBranch="$("$SELFDIR/git-default-branch.sh")"
currentBranch="$(git symbolic-ref --short HEAD)"

if [[ "$defaultBranch" == "$currentBranch" ]]
then
	>&2 echo "Already on the default branch $defaultBranch. Cannot auto-squash."
fi

mergebase="$(git merge-base "$defaultBranch@{upstream}" HEAD)"
nCommits="$(git rev-list --count "$mergebase"..HEAD)"

if [[ "$nCommits" == "0" || "$nCommits" == "1" ]]
then
	exit 0
fi

nToSquash=$(expr $nCommits - 1)

echo "Squashing $nToSquash commits onto $(git name-rev --name-only --always $mergebase)"

echo "> git reset --soft HEAD~$nToSquash"
git reset --soft HEAD~$nToSquash

echo "> git add $respositoryRootDir"
git add "$repositoryRootDir"

echo "> git commit --amend --edit"
git commit --amend --edit

if [[ "$PUSH" == "1" ]]
then
	echo "> git push --force-with-lease"
  git push --force-with-lease
fi
