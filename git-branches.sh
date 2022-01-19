#!/bin/bash

# Usage: Lists local branches in reverse order of latest commit with iso and relative dates
#        Also lists the branch description if it has one set alongside it.

function listBranchWithDescription() {
  branches=`git for-each-ref --format='%(committerdate:iso8601) %(committerdate:relative) %(refname)' --sort -committerdate refs/heads/`

  # requires git > v.1.7.9

  # you can set branch's description using command
  # git branch --edit-description

  # you can see branch's description using
  # git config branch.<branch name>.description

  while read -r branch; do
    clean_branch_name=`echo $branch | sed -E "s/.*refs\/heads\///g"`
    branch=`echo $branch | sed -E "s/refs\/heads\///g"`

    description=`git config branch.$clean_branch_name.description`
    printf "%-80s %s\n" "$branch" "$description" 
  done <<< "$branches"
}

listBranchWithDescription "$@"
