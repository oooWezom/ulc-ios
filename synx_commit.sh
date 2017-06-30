#!/bin/sh

#  NewCommitWithSynxScript.sh
#  ULC
#
#  Created by Alexey on 8/9/16.
#  Copyright © 2016 wezom.com.ua. All rights reserved.

echo "Enter a commit message: "
read -r commit

while [ "$commit" = "" ]; do
    echo "Enter a commit message: "
    read -r commit
done

echo "Enter branch name: "
read -r branch

while [ "$branch" = "" ]; do
    echo "Enter branch name: "
    read -r branch
done

git add . && git commit -am "$commit" && ./SynxScript.sh && git add . && git commit -am "Synx project" && git push -u origin "$branch"

