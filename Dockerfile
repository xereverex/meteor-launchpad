FROM node:8.15-jessie-slim

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV APP_BUNDLE_DIR /opt/meteor/dist
ENV BUILD_SCRIPTS_DIR /opt/build_scripts

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR

RUN chmod -R 750 $BUILD_SCRIPTS_DIR && \
  $BUILD_SCRIPTS_DIR/install-deps.sh && \
  $BUILD_SCRIPTS_DIR/install-meteor.sh && \
  $BUILD_SCRIPTS_DIR/post-install-cleanup.sh && \

# copy the app to the container
ONBUILD COPY . $APP_SOURCE_DIR

# install all dependencies, build app, clean up
ONBUILD RUN cd $APP_SOURCE_DIR && \
  $BUILD_SCRIPTS_DIR/build-meteor.sh && \
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
