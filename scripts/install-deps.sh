#!/bin/bash

set -e

printf "\n[-] Installing base OS dependencies...\n\n"

# install base dependencies
echo -e "deb http://deb.debian.org/debian jessie main\ndeb http://security.debian.org jessie/updates main" > /etc/apt/sources.list
apt-get update

# ensure we can get an https apt source if redirected
# https://github.com/jshimko/meteor-launchpad/issues/50
apt-get install -y apt-transport-https ca-certificates

if [ -f $APP_SOURCE_DIR/launchpad.conf ]; then
  source <(grep APT_GET_INSTALL $APP_SOURCE_DIR/launchpad.conf)
fi

apt-get install -y --no-install-recommends curl bzip2 bsdtar build-essential python git wget


# install gosu

dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"

wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$dpkgArch"
wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-$dpkgArch.asc"

export GNUPGHOME="$(mktemp -d)"

gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu

rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc

chmod +x /usr/local/bin/gosu

gosu nobody true
