#!/bin/bash

# https://gist.github.com/robwierzbowski/5430952/
# Create and push to a new github repo from the command line.  
# Grabs sensible defaults from the containing folder and `.gitconfig`.  
# Refinements welcome.

# Gather constant vars
CURRENTDIR=${PWD##*/}
GITHUBUSER=$(git config github.user)

GITUSER="${GITUSER-linuxha}"

#
prompt() {
    echo -n "${1-Press Enter to continue: }"
    read choice
}

# Get user input
# These didn't work with my BASH (4.3.30(1)-release)
#read "REPONAME?New repo name (enter for ${PWD##*/}):"
#read "USER?Git Username (enter for ${GITHUBUSER}):"
#read "DESCRIPTION?Repo Description:"

read -p "New repo name (enter for ${PWD##*/}): " REPONAME
REPONAME="${REPONAME:-${CURRENTDIR}}"

# You have to purchase the private github service
if [ 0 -eq 1 ]; then
    read -p "Private (y/N): " PRIVATE
    if [ "x${PRIVATE,,}" == "xy" ]; then
	echo "${REPONAME} will be Private"
	PRIVATE="true"
    else
	echo "${REPONAME} will be Public"
    PRIVATE="false"
    fi
else
        PRIVATE="false"
fi

read -p "Git Username (enter for ${GITHUBUSER}): " USER
read -p "Repo Description (Enter to finish): " DESCRIPTION

echo "Here we go..."

#if [ 1 -eq 1 ]; then
# Curl some json to the github API oh damn we so fancy
curl -u ${USER:-${GITHUBUSER}} https://api.github.com/user/repos -d "{\"name\": \"${REPONAME}\", \"description\": \"${DESCRIPTION}\", \"private\": ${PRIVATE}, \"has_issues\": true, \"has_downloads\": true, \"has_wiki\": false}"
REPORT=$?
if [ $REPORT -eq 0 ]; then
   echo "${REPONAME} create successfully"
else
   echo "${REPONAME} failed (${REPORT})"
   exit ${REPORT}
fi

git init
git add .
echo "# ${REPOS} Readem" >> README.md
git add README.md
git commit -m "first commit"
#fi

# Set the freshly created repo to the origin and push
# You'll need to have added your public key to your github account
# git@... should work for ssh
#git remote set-url origin git@github.com:${USER:-${GITHUBUSER}}/${REPONAME:-${CURRENTDIR}}.git
git remote add origin git@github.com:${USER:-${GITHUBUSER}}/${REPONAME:-${CURRENTDIR}}.git
# To change
# git remote set-url origin git@github.com:<Username>/<Project>.git or https://...
git remote -v
git push --set-upstream origin master

exit $?
