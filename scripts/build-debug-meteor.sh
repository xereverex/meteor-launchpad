#!/bin/bash

#
# builds a production meteor bundle directory
#
set -e

# Fix permissions warning in Meteor >=1.4.2.1 without breaking
# earlier versions of Meteor with --unsafe-perm or --allow-superuser
# https://github.com/meteor/meteor/issues/7959
export METEOR_ALLOW_SUPERUSER=true

cp -r $NPM_DIRECTORY/node_modules $APP_SOURCE_DIR/node_modules
cp  $NPM_DIRECTORY/package-lock.json $APP_SOURCE_DIR/package-lock.json
cd $APP_SOURCE_DIR

# Install app deps
printf "\n[-] Running npm install in app directory...\n\n"
meteor npm -v
meteor npm cache verify
meteor npm install --debug

# build the bundle
printf "\n[-] Building Meteor application...\n\n"
mkdir -p $APP_BUNDLE_DIR
meteor build --debug --directory $APP_BUNDLE_DIR --server-only --verbose

# run npm install in bundle
printf "\n[-] Running npm install in the server bundle...\n\n"
cd $APP_BUNDLE_DIR/bundle/programs/server/
meteor npm cache verify
meteor npm install --debug

# put the entrypoint script in WORKDIR
mv $BUILD_SCRIPTS_DIR/entrypoint.sh $APP_BUNDLE_DIR/bundle/entrypoint.sh

# change ownership of the app to the node user
chown -R node:node $APP_BUNDLE_DIR
