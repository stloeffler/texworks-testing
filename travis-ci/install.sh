#!/usr/bin/env sh

#INSTALLER_URL="ftp://tug.org/historic/systems/texlive/2018/install-tl-unx.tar.gz"
INSTALLER_URL="http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"

# Exit on errors
set -e

. "${TRAVIS_BUILD_DIR}/travis-ci/defs.sh"

print_headline "Installing TeX"

echo_and_run "ls /usr/local"
echo_and_run "ls /usr/local/bin"

mkdir -p /tmp/install-tl

echo_and_run "wget -O install-tl-unx.tar.gz \"${INSTALLER_URL}\""
echo_and_run "tar --extract --file install-tl-unx.tar.gz --strip-components=1 --directory /tmp/install-tl"
echo_and_run "sed -ie 's|\$HOME|$HOME|' \"${TRAVIS_BUILD_DIR}/travis-ci/texlive.profile\""
echo_and_run "/tmp/install-tl/install-tl -profile \"${TRAVIS_BUILD_DIR}/travis-ci/texlive.profile\""

export PATH="$HOME/texlive/2018/bin/x86_64-linux:$PATH"

tlmgr install fncychap lm luaotfload sectsty
