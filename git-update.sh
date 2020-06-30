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

echo -e "\e[2;96m> git fetch\e[0m"
git fetch

case "$method" in
	"--merge")
		echo -e "\e[2;96m> git merge origin/$defaultBranch\e[0m"
		git merge "origin/$defaultBranch"
		;;

	"--rebase")
		echo -e "\e[2;96m> git rebase origin/$defaultBranch\e[0m"
		git rebase "origin/$defaultBranch"
		;;
	*)
		>&2 echo "Unknown internal error"
		exit 128
esac

unmerged="$(git ls-files -u)"
if [[ "$unmerged" != "" ]]
then
	>&2 echo -e "\e[1;31mYou have unresolved conflicts!\e[0m"
	exit
fi

case "$method" in
	"--merge")
		echo -e "\e[2;96m> git push\e[0m"
		git push
		;;
	"--rebase")
		echo -e "\e[2;96m> git push --force-with-lease\e[0m"
		git push --force-with-lease
		;;
	*)
		>&2 echo "Unknown internal error"
		exit 128
esac
