FROM debian:jessie

RUN groupadd -r node && useradd -m -g node node

# Gosu
ENV GOSU_VERSION 1.10

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV APP_BUNDLE_DIR /opt/meteor/dist
ENV BUILD_SCRIPTS_DIR /opt/build_scripts
ENV NPM_DIRECTORY /opt/meteor/npm

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
RUN chmod -R 750 $BUILD_SCRIPTS_DIR
ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-8.9.0}

ARG TOOL_NODE_FLAGS
ENV TOOL_NODE_FLAGS $TOOL_NODE_FLAGS

# optionally custom apt dependencies at app build time
RUN if [ "$APT_GET_INSTALL" ]; then apt-get update && apt-get install -y $APT_GET_INSTALL; fi

RUN $BUILD_SCRIPTS_DIR/install-deps.sh
RUN $BUILD_SCRIPTS_DIR/install-node.sh
RUN $BUILD_SCRIPTS_DIR/install-meteor.sh

COPY . $NPM_DIRECTORY
RUN cd $NPM_DIRECTORY && export METEOR_ALLOW_SUPERUSER=true && meteor npm install --debug
RUN cd $NPM_DIRECTORY/server-npm && export METEOR_ALLOW_SUPERUSER=true && meteor npm install --debug

# copy the app to the container
ONBUILD COPY . $APP_SOURCE_DIR

# install all dependencies, build app, clean up
ONBUILD RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/build-debug-meteor.sh && \
  $BUILD_SCRIPTS_DIR/post-build-cleanup.sh

# Default values for Meteor environment variables
ENV ROOT_URL http://localhost
ENV MONGO_URL mongodb://127.0.0.1:27017/meteor
ENV PORT 3000

EXPOSE 3000

WORKDIR $APP_BUNDLE_DIR/bundle

# start the app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "main.js"]
