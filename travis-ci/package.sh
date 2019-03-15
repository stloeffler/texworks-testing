#!/bin/sh

. "${TRAVIS_BUILD_DIR}/travis-ci/defs.sh"

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
	print_warning "Not packaging pull-requests for deployment"
	exit 0
fi

${TRAVIS_BUILD_DIR}/travis-ci/bintray/package.sh
#${TRAVIS_BUILD_DIR}/travis-ci/launchpad/package.sh
