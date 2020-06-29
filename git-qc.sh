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
currentBranchName="$(git name-rev --no-undefined --name-only HEAD)"
upstream="$(git branch --points-at HEAD "--format=%(upstream)" "$currentBranchName")"
localShaBefore="$(git rev-parse --verify -q HEAD)"

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

if [[ "$upstream" == "" ]]
then
	echo "> git push --set-upstream origin $currentBranchName"
	git push --set-upstream origin "$currentBranchName"
else
  git fetch origin "$upstream"
  upstreamSha="$(git rev-parse --verify -q "$upstream" 2> /dev/null)"
  if [[ "$upstreamSha" != "$localShaBefore" ]]
  then
  	echo -e "\e[1;31mThe upstream has changed. These commits have been added/removed:\e[0m"
  	echo "> git --no-pager log $localShaBefore..$upstreamSha"
  	git --no-pager log "$localShaBefore..$upstreamSha"
  	echo
  	echo -e "\e[1;31mRebase onto these? [Y/n]\e[0m"
  	doRebase=$(askYesNo)
  	echo 
  	if [[ "$doRebase" == "true" ]]
  	then
  		echo "> git rebase --onto $upstream"
  		git rebase --onto "$upstream"

  		unmerged="$(git ls-files -u)"
  		if [[ "$unmerged" != "" ]]
  		then
  		  >&2 echo -e "\e[1;31mYou have unresolved conflicts!\e[0m"
  		  exit 1
  		fi
  	fi
  fi
  echo "> git push --force-with-lease=$upstreamSha"
	git push "--force-with-lease=$upstreamSha"
fi
