#!/bin/bash

SELFDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}" )")"

PUSH=1
REBASE=0

while [[ "$#" != "0" ]]
do
	found=0
	case "$1" in
		"--no-push")
			PUSH=0
			found=1
			shift
			;;
		"--rebase")
			REBASE=1
			found=1
			shift
			;;
	esac

	if [[ "$found" == "0" ]]
	then
		break
	fi
done

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

if [[ "$REBASE" == "1" ]]
then
		mergebase="$defaultBranch@{upstream}"
fi

commitMessageFile="$(mktemp)"
git log --format=%B -n $nCommits HEAD > "$commitMessageFile"

echo "Squashing $nToSquash commits onto $(git name-rev --name-only --always $mergebase)"

if [[ "$REBASE" == "1" ]]
then
	echo "> git reset --soft $mergebase"
	git reset --soft "$mergebase"
else
	echo "> git reset --soft HEAD~$nToSquash"
	git reset --soft HEAD~$nToSquash
fi

echo "> git add $respositoryRootDir"
git add "$repositoryRootDir"

if [[ "$REBASE" == "1" ]]
then
	echo "> git commit"
  git commit --edit "--file=$commitMessageFile"
else
	echo "> git commit --amend"
	git commit --amend --edit "--file=$commitMessageFile"
fi

if [[ "$PUSH" == "1" ]]
then
	echo "> git push --force-with-lease"
  git push --force-with-lease
fi
