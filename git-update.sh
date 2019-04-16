#!/bin/bash

SELFDIR="$( realpath "$(dirname "${BASH_SOURCE[0]}" )")"

method=

case "$1" in
	"--merge"|"--rebase")
		method=$1
		;;
	"-m")
		method=--merge
		;;
	"-r"|"")
		method=--rebase
		;;
	*)
		>&2 echo "Unknown update method $1, use --merge, -m, --rebase, or -r"
		exit 127
		;;
esac

set -e
defaultBranch="$( "$SELFDIR/git-default-branch.sh" )"
currentBranch="$(git name-rev --name-only HEAD)"

if [[ "$defaultBranch" == "$currentBranch" ]]
then
	>&2 echo "Already on default branch $defaultBranch"
	exit
fi

# set -e causes an abort if working dir is dirty.
"$SELFDIR/git-dirty.sh"

echo "> git fetch"
git fetch

case "$method" in
	"--merge")
		echo "> git merge origin/$defaultBranch"
		git merge "origin/$defaultBranch"
		;;

	"--rebase")
		echo "> git rebase origin/$defaultBranch"
		git rebase "origin/$defaultBranch"
		;;
	*)
		>&2 echo "Unknown internal error"
		exit 128
esac

unmerged="$(git ls-files -u)"
if [[ "$unmerged" != "" ]]
then
	>&2 echo "You have unresolved conflicts!"
	exit
fi

case "$method" in
	"--merge")
		echo "> git push"
		git push
		;;
	"--rebase")
		echo "> git push --force-with-lease"
		git push "--force-with-lease"
		;;
	*)
		>&2 echo "Unknown internal error"
		exit 128
esac
