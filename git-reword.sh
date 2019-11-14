#!/bin/bash

set -e

SELFDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}" )")"
"$SELFDIR/git-dirty.sh"

message="`git log -1 --format=format:%B`"
newMessageFile="`mktemp`"
echo "$message" > "$newMessageFile"

git commit --amend --edit "--file=$newMessageFile"
rm $newMessageFile
