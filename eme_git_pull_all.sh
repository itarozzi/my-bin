#! /bin/bash
set -u

REPO_PATH="$HOME/software-projects/AndroidStudioProjects"

EME_REPOS=$(ls -d $REPO_PATH/EME-*)

for repo in $EME_REPOS; do

  echo "sync repo: $repo"
  # Pull remote changes
  cd $repo
  git pull --all
  cd ..

done

cd $REPO_PATH
gitcheck
