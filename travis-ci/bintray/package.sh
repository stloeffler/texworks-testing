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
		{"includePattern": "pdf/([-_a-zA-Z]+)/(TeXworks-manual-[-_a-zA-Z]+.pdf)", "uploadPattern": "\$2"},
		{"includePattern": "html/TeXworks-manual-html-[0-9]+-${GIT_HASH}.zip", "uploadPattern": "TeXworks-manual-html.zip"}
	],
	"publish": true
}
EOF
