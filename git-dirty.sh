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
	exit 127
fi

exit 0
