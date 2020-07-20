#!/bin/bash

set -e

SELFDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}" )")"
"$SELFDIR/git-dirty.sh"

push=false
branch=$(git rev-parse --short --abbrev-ref=loose HEAD 2>/dev/null)
if [[ "$branch" != "HEAD" ]]
then
	upstream="$(git branch --points-at HEAD "--format=%(upstream)" "$branch")"
	if [[ "$upstream" != "" ]]
	then
	  localSha="$(git rev-parse --verify -q --branch "$branch")"
  	remoteSha="$(git rev-parse --verify -q --branch "$upstream")"
	  if [[ "$localSha" == "$remoteSha" ]]
  	then
  		push=true
  	fi
  fi
fi

message="`git log -1 --format=format:%B`"
newMessageFile="`mktemp`"
echo "$message" > "$newMessageFile"

git commit --amend --edit "--file=$newMessageFile"
rm $newMessageFile

if [[ "$push" == "true" ]]
then
	git push --force-with-lease
fi
