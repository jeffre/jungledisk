#!/bin/sh
set -ex

URL="https://downloads.jungledisk.com/${VERSION}/"

# OS architecture determines which package to download
if uname -m | grep -q "x86_64"; then
  FILE="junglediskworkgroup_amd64.deb"
elif uname -m | grep -q "i686"; then
  FILE="junglediskworkgroup_i686.deb"
else
  echo "Unrecognized platform: $(uname -m)"
  exit 1
fi

jd_deb="/tmp/junglediskworkgroup.deb"

# Only download the file if it doesnt already exist on disk
if ! [ -f "$FILE" ]; then
  curl -s "$URL$FILE" -o "$jd_deb"
fi

# Installation
dpkg -i "$jd_deb"

# Clean up
rm -f "$jd_deb"
