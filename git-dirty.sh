#!/bin/bash

set -e

workingDirDirty=0
if [[ "$(git diff --stat)" != '' ]]
then
         workingDirDirty=1
fi

if [[ "$(git ls-files -u)" != '' ]]
then
	workingDirDirty=1
fi

if [[ "$workingDirDirty" == "1" ]]
then
  >&2 printf '\033[1;31mYour working directory is dirty.\033[0m\n'
	exit 127
fi

exit 0
