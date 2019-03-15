#!/bin/sh

# Exit on errors
set -e

. "${TRAVIS_BUILD_DIR}/travis-ci/defs.sh"

print_headline "Packaging for Bintray"

GIT_HASH=$(git --git-dir=".git" show --no-patch --pretty="%h")
GIT_DATE=$(git --git-dir=".git" show --no-patch --pretty="%ci")
DATE_HASH=$(date -u +"%Y%m%d%H%M")
VERSION="0.1.1"
VERSION_NAME="${VERSION}-${DATE_HASH}-git_${GIT_HASH}"
LANGS=$(cd ${TRAVIS_BUILD_DIR}/src && echo */ | tr -d '/')

RELEASE_DATE=$(date -u +"%Y-%m-%dT%H:%M:%S%z" --date="${GIT_DATE}")

echo_var "GIT_HASH"
echo_var "GIT_DATE"
echo_var "VERSION_NAME"
echo_var "LANGS"

echo_and_run "ls ${TRAVIS_BUILD_DIR}/pdf/"

echo_and_run "ls ${TRAVIS_BUILD_DIR}/html/"

cat > "${TRAVIS_BUILD_DIR}/travis-ci/bintray/bintray.json" <<EOF
{
	"package": {
		"name": "Latest-TeXworks-Manual",
		"repo": "generic",
		"subject": "stloeffler"
	},
	"version": {
		"name": "${VERSION_NAME}",
		"released": "${RELEASE_DATE}",
		"gpgSign": false
	},
	"files":
	[
		{"includePattern": "pdf/([-_a-zA-Z]+)/TeXworks-manual-([-_a-zA-Z]+).pdf", "uploadPattern": "TeXworks-manual-${VERSION_NAME}-\$1.pdf"},
		{"includePattern": "html/TeXworks-manual-(.*).zip", "uploadPattern": "TeXworks-manual-${VERSION_NAME}-html.zip"}
	],
	"publish": true
}
EOF

echo_and_run "cat ${TRAVIS_BUILD_DIR}/travis-ci/bintray/bintray.json"
