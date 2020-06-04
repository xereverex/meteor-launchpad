FROM node:8.15-jessie-slim

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV APP_BUNDLE_DIR /opt/meteor/dist
ENV BUILD_SCRIPTS_DIR /opt/build_scripts
ENV NPM_DIRECTORY /opt/meteor/npm

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
COPY npm $NPM_DIRECTORY

printf "\n[-] Install meteor and npm modules...\n\n"
RUN chmod -R 750 $BUILD_SCRIPTS_DIR && \
  $BUILD_SCRIPTS_DIR/install-deps.sh && \
  $BUILD_SCRIPTS_DIR/install-meteor.sh && \
  $BUILD_SCRIPTS_DIR/post-install-cleanup.sh && \
  cd $NPM_DIRECTORY && export METEOR_ALLOW_SUPERUSER=true &&  meteor npm install --debug

ENV ROOT_URL http://localhost
ENV MONGO_URL mongodb://127.0.0.1:27017/meteor
ENV PORT 3000
EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]
printf "\n[-] Copy sources...\n\n"
ONBUILD COPY . $APP_SOURCE_DIR
printf "\n[-] Update npm modules...\n\n"
ONBUILD RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/install-npm-debug-multistage.sh && \
  meteor list
