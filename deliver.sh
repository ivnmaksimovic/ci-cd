#!/usr/bin/env bash

# Usage
# ./deliver.sh -c conf/example.conf -v v1.27.0

# Conventions and requirements
# Server permisions and ssh are allowed for user.
# Tag version on your own. This delivers the current branch!

# TODO check https://www.npmjs.com/package/commander
# - enhance script https://codeburst.io/13-tips-tricks-for-writing-shell-scripts-with-awesome-ux-19a525ae05ae
# - check boilerplate https://github.com/kvz/bash3boilerplate/blob/master/main.sh
# - use params that are not single letter like with getopts
# - maybe convert all to npm script using something like:
#   - https://www.npmjs.com/search?q=ssh
#   - https://www.npmjs.com/package/tar

# Source nvm so it can be used from script
. ~/.nvm/nvm.sh

helpFunction()
{
   printf -- "\n"
   printf -- "Usage: $0 -c myapp -v v1.27.0 \n"
   printf -- "\t to use myapp.conf and deliver as version v1.27.0 \n"
   printf -- "\t Each config file is for 1 project \n"
   exit 1 # Exit script after printing help
}

while getopts "c:v:" opt
do
   case "$opt" in
      c ) CONFIG="$OPTARG" ;;
      v ) VERSION="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "${CONFIG}" ] || [ -z "${VERSION}" ]
then
   printf -- "-c or -v param is empty. You have to specify both config and version \n";
   helpFunction
fi

# Include params from .conf file
# source a script relative to current https://stackoverflow.com/a/12694189/2722212
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "${DIR}/${CONFIG}"

printf -- "Preparing the delivery... \n"
printf -- "APPNAME: ${APPNAME} \n"
printf -- "VERSION: ${VERSION} \n"
printf -- "SERVER_IP: ${SERVER_IP} \n"
printf -- "SERVER_USER: ${SERVER_USER} \n"
printf -- "SERVER_BUILDS_PATH: ${SERVER_BUILDS_PATH} \n"
printf -- "PROJECT_PATH: ${PROJECT_PATH} \n"
printf -- "BUILD_PATH: ${BUILD_PATH} \n"

##########
# Go to folder to be able to run npm scripts...
cd ${PROJECT_PATH}

##########
# Manually tag and commit version to deliver
# Maybe use npm version something...
# https://www.npmjs.com/package/semantic-release
# https://www.npmjs.com/package/semver

##########
# Gets the latest tag
LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
printf -- "Previous version was ${LATEST_TAG}\n"
printf -- "New version is ${VERSION}\n"

##########
# Run tests
printf -- "Running tests...\n"
# npm run test
RUN_TESTS

##########
# Build for production
printf -- "Building for production...\n"
# npm run build-prod
RUN_PRODUCTION_BUILD

##########
# Deliver new release to server
# 1. Make archive from BUILD_PATH (ex. dist or build)
# 2. ssh to server with the archive
# 3. Create directory structure if it does not exists
# 4. Unpack the 
# 5. Clear folder just in case the same version is being delivered
# 6. Rename the build folder to version (ex. builds/dist to builds/v1.27.0)
printf -- "Creating archive of build, gziping, uploading...\n"
printf -- "Unpacking on server to folder ~/apps/${APPNAME}/builds/${VERSION}\n"

tar czv ${BUILD_PATH} | \
ssh ${SERVER_USER}@${SERVER_IP} \
"mkdir -p ${SERVER_BUILDS_PATH} && \
cat | tar xz -C ${SERVER_BUILDS_PATH} && \
rm -rf ${SERVER_BUILDS_PATH}/${VERSION} && \
mv ${SERVER_BUILDS_PATH}/${BUILD_PATH} ${SERVER_BUILDS_PATH}/${VERSION}"

##########
# Done
printf -- "\033[32m SUCCESS: ${VERSION} delivered to ${SERVER_IP} ${SERVER_BUILDS_PATH} \033[0m \n"
printf -- "\n"
exit 0;
