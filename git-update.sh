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
currentBranch="$(git symbolic-ref --short HEAD)"

if [[ "$defaultBranch" == "$currentBranch" ]]
then
	>&2 echo "Already on default branch $defaultBranch"
	exit
fi

# set -e causes an abort if working dir is dirty.
"$SELFDIR/git-dirty.sh"

printf '\033[2;96m> git fetch\033[0m\n'
git fetch

case "$method" in
	"--merge")
		printf '\033[2;96m> git merge origin/$defaultBranch\033[0m\n'
		git merge "origin/$defaultBranch"
		;;

	"--rebase")
		printf '\033[2;96m> git rebase origin/$defaultBranch\033[0m\n'
		git rebase "origin/$defaultBranch"
		;;
	*)
		>&2 echo "Unknown internal error"
		exit 128
esac

unmerged="$(git ls-files -u)"
if [[ "$unmerged" != "" ]]
then
	>&2 printf '\033[1;31mYou have unresolved conflicts!\033[0m\n'
	exit
fi

case "$method" in
	"--merge")
		printf '\033[2;96m> git push\033[0m\n'
		git push
		;;
	"--rebase")
		printf '\033[2;96m> git push --force-with-lease\033[0m\n'
		git push --force-with-lease
		;;
	*)
		>&2 echo "Unknown internal error"
		exit 128
esac
