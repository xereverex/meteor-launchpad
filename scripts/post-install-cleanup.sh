#!/bin/bash
set -e

printf "\n[-] Performing post install cleanup...\n\n"

# Clean out docs
rm -rf /usr/share/{doc,doc-base,man,locale,zoneinfo}

# Clean out package management dirs
rm -rf /var/lib/{cache,log}

# clean additional files created outside the source tree
rm -rf /root/{.cache,.config,.local}
rm -rf /tmp/*

apt-get purge -y --auto-remove apt-transport-https build-essential bsdtar bzip2 ca-certificates curl git python
apt-get -y autoremove
apt-get -y clean
apt-get -y autoclean
rm -rf /var/lib/apt/lists/*
