#!/bin/bash

#
# builds a production meteor bundle directory
#
set -e

# Fix permissions warning in Meteor >=1.4.2.1 without breaking
# earlier versions of Meteor with --unsafe-perm or --allow-superuser
# https://github.com/meteor/meteor/issues/7959
export METEOR_ALLOW_SUPERUSER=true

cd $APP_SOURCE_DIR
# build the bundle
printf "\n[-] Building Meteor application...\n\n"
mkdir -p $APP_BUNDLE_DIR
meteor build --debug --directory $APP_BUNDLE_DIR --server-only --verbose
mv $BUILD_SCRIPTS_DIR/entrypoint.sh $APP_BUNDLE_DIR/bundle/entrypoint.sh
chown -R node:node $APP_BUNDLE_DIR
# run npm install in bundle
