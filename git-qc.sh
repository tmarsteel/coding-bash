#!/bin/bash

set -e

function askYesNo {
	read -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	  echo "true"
  else
  	echo "false"
  fi
}

gitRootDir="$(git rev-parse --show-toplevel 2> /dev/null)"
currentBranchName="$(git name-rev --no-undefined --name-only --exclude "refs/tags/*" HEAD)"
upstream="$(git branch --points-at HEAD "--format=%(upstream)" "$currentBranchName")"
localShaBefore="$(git rev-parse --verify -q HEAD)"

prefix=
if [[ "$currentBranchName" =~ ^([A-Za-z0-9]{2,}-[0-9]+)(-|$) ]]
then
	prefix="${BASH_REMATCH[1]}: "
fi

message=$@

printf '\033[2;96m> git add $gitRootDir\033[0m\n'
git add "$gitRootDir"

printf '\033[2;96m> git commit -m $prefix$message\033[0m\n'
git commit -m "$prefix$message"

set +e

if [[ "$upstream" == "" ]]
then
	printf '\033[2;96m> git push --set-upstream origin $currentBranchName\033[0m\n'
	git push --set-upstream origin "$currentBranchName"
else
  git fetch
  upstreamSha="$(git rev-parse --verify -q "$upstream" 2> /dev/null)"
  if [[ "$upstreamSha" != "$localShaBefore" ]]
  then
  	printf '\033[1;31mThe upstream has changed. These commits have been added/removed:\033[0m\n'
  	printf '\033[2;96m> git --no-pager log $localShaBefore..$upstreamSha\033[0m\n'
  	git --no-pager log "$localShaBefore..$upstreamSha"
  	echo
  	printf '\033[1;31mRebase onto these? [Y/n]\033[0m\n'
  	doRebase=$(askYesNo)
  	echo
  	if [[ "$doRebase" == "false" ]]
  	then
  	  printf '\033[1;32mNot rebasing, not pushing.\033[0m\n'
  	  exit 1
  	fi

		printf '\033[2;96m> git rebase --onto $upstream\033[0m\n'
		git rebase --onto "$upstream"

		unmerged="$(git ls-files -u)"
		if [[ "$unmerged" != "" ]]
		then
		  >&2 printf '\033[1;31mYou have unresolved conflicts!\033[0m\n'
		  exit 1
  	fi
  fi

	printf '\033[2;96m> git push\033[0m\n'
  git push
fi
