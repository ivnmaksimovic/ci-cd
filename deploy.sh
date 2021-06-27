#!/usr/bin/env bash

# Usage
# ./deploy.sh -a myapp.com -v v1.22.0

helpFunction()
{
   printf -- "\n"
   printf -- "Usage: $0 -a myapp.com -v v1.27.0 \n"
   printf -- "\t-a app name like myapp.com \n"
   printf -- "\t-v version name like v1.22.0 \n"
   exit 1 # Exit script after printing help
}

while getopts "a:v:" opt
do
   case "$opt" in
      a ) APPNAME="$OPTARG" ;;
      v ) VERSION="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "${APPNAME}" ] || [ -z "${VERSION}" ]
then
   printf -- "Some or all of the parameters are empty \n";
   helpFunction
fi

SERVER_ROOT="/var/www"
LOGED_IN_USER=${SUDO_USER}

printf -- "Deploying... \n"
printf -- "APPNAME: ${APPNAME} \n"
printf -- "VERSION: ${VERSION} \n"

# Builds are delivered to user folders, but
# server don't have permision to access user folders.
# Copy from user/apps to /apps so server can access it.
printf -- "Copying to /apps...\n"
mkdir /apps/${APPNAME} # in case dir does not exists yet
cp -R /home/${SUDO_USER}/apps/${APPNAME}/builds /apps/${APPNAME}

# List copied content
ls /apps/${APPNAME}/builds

# Symlink /apps to /var/www
printf -- "Creating symbolic link: \n"
printf -- "${SERVER_ROOT}/${APPNAME} -> /apps/${APPNAME}/builds/${VERSION}/ \n"

ln -sfn /apps/${APPNAME}/builds/${VERSION}/ ${SERVER_ROOT}/${APPNAME}

##########
# Done
printf -- "\033[32m SUCCESS: ${VERSION} is in production \033[0m \n"
printf -- "\n"
exit 0;