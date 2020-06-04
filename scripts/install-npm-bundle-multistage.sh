#!/bin/bash

#
# builds a production meteor bundle directory
#
set -e

# Fix permissions warning in Meteor >=1.4.2.1 without breaking
# earlier versions of Meteor with --unsafe-perm or --allow-superuser
# https://github.com/meteor/meteor/issues/7959
export METEOR_ALLOW_SUPERUSER=true

printf "\n[-] Running npm install in the server bundle...\n\n"
cd $APP_BUNDLE_DIR/bundle/programs/server/
meteor npm cache verify
meteor npm install --production
