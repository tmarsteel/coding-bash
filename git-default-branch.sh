#!/bin/bash

defaultBranches=(develop master)

for defaultBranchName in ${defaultBranches[@]};
do
	git rev-parse "origin/$defaultBranchName" 1>/dev/null 2>/dev/null
        if [ "$?" == "0" ]
        then
                echo "$defaultBranchName"
                exit 0
        fi
done

>&2 echo "Default branch not found."
exit 1
