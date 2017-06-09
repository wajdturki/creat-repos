#!/bin/bash

VERSION="1.01.02"	     # Semantic versioning, version number MAJOR.MINOR.PATCH

# https://gist.github.com/robwierzbowski/5430952/
# Create and push to a new github repo from the command line.  
# Grabs sensible defaults from the containing folder and `.gitconfig`.  
# Refinements welcome.

GITHOMEDIR="${GITHOMEDIR-${HOME}/dev/git}"
OPTIND=1 # Reset in case getopts has been used in shell

# -[ Help ]---------------------------------------------------------------------
NOM=$(basename $0)
# Yes, this is typically over kill but I've gotten into the habit of adding help
# for my sanity at later dates. At least it gives me an idea of what the heck I
# was thinking when I wrote this thing.
HelpStr="
${NOM} - create a GITHUB Repository\n
The default (no options) will create a repos from the current directory (and include all the files in the \"first commit\". If the -d DIR is passed, ${NOM} will attempt to create the full path to the directory. If the DIR path starts with a / (slash) it will attempt to create the DIR referenced from Root. If it does not then the DIR path will be appended to ${GITHOMEDIR}/. Errors will exit the script\n
${NOM} [-h|?] [-V] [-d DIR]
\t-h\thelp and exit
\t-V\tPrint version and exit
\t-w\tuse the web URI instead of the ssh URI
\t-d\tcreate a new repo DIR under ${GITHOMEDIR}
\t\tif the directory doesn't exist it will be create
"
print_usage() {
    echo -e "${HelpStr}"    
}

# -[ Options ]------------------------------------------------------------------
USE_WEB=''
QUIET=0

while getopts "d:h?qwV" opt; do
    case $opt in
	d)
	    REPODIR=$OPTARG
	    # if the REPODIR starts with a / then it's absolute,
	    # don't prepend ${GITHOMEDIR}
	    if [ "${REPODIR,,/}" == "/" ]; then
		PROJECTPATH="${REPODIR}"
	    else
		PROJECTPATH="${GITHOMEDIR}/${REPODIR}"
	    fi

	    if [ -d "${PROJECTPATH}" ]; then
		echo "${PROJECTPATH} exists"
	    else
		echo "${PROJECTPATH} doesn't exist, creating"
		mkdir -p "${PROJECTPATH}"
		REPORT=$?
		if [ $REPORT -eq 0 ]; then
		    echo "${PROJECTPATH} create successfully"
		else
		    echo "New project directory: ${PROJECTPATH} failed (${REPORT})"
		    exit ${REPORT}
		fi
	    fi
	    cd "${PROJECTPATH}"
	    echo "Now in ${PWD}"
	    ;;
	V)
	    echo "$(basename $0) v$VERSION"
	    exit 1
	    ;;
	w)
	    # This is untested as I always use the SSH URI
	    USE_WEB=1
	    echo "Switching to adding the web URI to origin"
	    ;;
	q)
	    # I don't have this setup yet
	    QUIET=1
	    ;;
	h|\?)
	    print_usage
	    exit 1
	    ;;
	*)
	    echo "Unknown option $OPTARG"
	    print_usage
	    exit 1
	    ;;
    esac
done

# -[ Main ]---------------------------------------------------------------------
# Gather constant vars
CURRENTDIR=${PWD##*/}

# get the github.user setting or default to the user's login
GITHUBUSER="$(git config github.user)"
GITHUBUSER="${GITHUBUSER-${USER}}"

# You can set these env vars externally
GIT_HAS_ISSUES="${GIT_HAS_ISSUES-true}"
GIT_HAS_DOWNLOADS="${GIT_HAS_DOWNLOADS-true}"
GIT_HAS_WIKI="${GIT_HAS_WIKI-false}"

#
prompt() {
    echo -n "${1-Press Enter to continue: }"
    read choice
}

# Get user input
read -p "New repo name (enter for ${CURRENTDIR}): " REPONAME
REPONAME="${REPONAME:-${CURRENTDIR}}"

# You have to purchase the private github service
if [ "x${GITPRIVATE}" == "x1" ]; then
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

# Curl some json to the github API oh damn we so fancy
STR=$(curl -u "${GITHUBUSER}" https://api.github.com/user/repos -d "{\"name\": \"${REPONAME}\", \"description\": \"${DESCRIPTION}\", \"private\": ${PRIVATE}, \"has_issues\": ${GIT_HAS_ISSUES}, \"has_downloads\": ${GIT_HAS_DOWNLOADS}, \"has_wiki\": ${GIT_HAS_WIKI}}")
REPORT=$?

# https://developer.github.com/v3/
# ------------------------------------------------------------------------------
# Hmm, I got this back
# {
#   "message": "Bad credentials",
#   "documentation_url": "https://developer.github.com/v3"
# }
# ------------------------------------------------------------------------------
#STR=$(echo $STR | python -c "import sys, json; print json.load(sys.stdin)['name']")
#STR=$(echo $STR | python3 -c "import sys, json; print(json.load(sys.stdin)['name'])")
STR=$(echo $STR | sed -e 's/[{}]/''/g' -e "s/\,/\n/g" | grep message | cut -d \" -f 4)
if [ -z "${STR}" ]; then
    echo "Message = '$STR'"
else
    echo "Message is blank"
fi

if [ $REPORT -eq 0 ]; then
  echo "${REPONAME} create successfully"
else
   echo "${REPONAME} failed (${REPORT})"
   exit ${REPORT}
fi

# ------------------------------------------------------------------------------

git init
git add .
# Yes I know it's spelled wrong :-)
echo "# ${REPONAME} Readem" >> README.md
git add README.md
git commit -m "first commit"


# Set the freshly created repo to the origin and push
# You'll need to have added your public key to your github account
# This is untested as I always use the SSH URI
if [ -z "$USE_WEB" ]; then
    git remote add origin git@github.com:${USER:-${GITHUBUSER}}/${REPONAME:-${CURRENTDIR}}.git
else
    git remote add origin https://github.com/:${USER:-${GITHUBUSER}}/${REPONAME:-${CURRENTDIR}}.git
fi
# To change
# git remote set-url origin git@github.com:<Username>/<Project>.git or https://...

git remote -v
git push --set-upstream origin master

exit $?
