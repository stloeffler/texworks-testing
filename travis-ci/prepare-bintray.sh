#!/usr/bin/env sh

set -v

pwd
#cat src/TWVersion.h
sed -nEe 's,^#define TEXWORKS_VERSION,,p' src/TWVersion.h
sed -nEe 's,^#define TEXWORKS_VERSION\s,,p' src/TWVersion.h
sed -nEe 's,^#define TEXWORKS_VERSION\t,,p' src/TWVersion.h
sed -nEe 's,^#define TEXWORKS_VERSION\\s,,p' src/TWVersion.h
sed -nEe 's,^#define TEXWORKS_VERSION\\t,,p' src/TWVersion.h
sed -nEe 's,^#define TEXWORKS_VERSION\s\+,,p' src/TWVersion.h
sed -nEe 's,^#define TEXWORKS_VERSION\s\+",,p' src/TWVersion.h
sed -nEe 's,^#define TEXWORKS_VERSION\s"\?\([0-9.]\+\)"\?$,\1,p' src/TWVersion.h

TW_VERSION=$(sed -ne 's,^#define TEXWORKS_VERSION\s"\?\([0-9.]\+\)"\?$,\1,p' src/TWVersion.h)
GIT_HASH=$(git --git-dir=".git" show --no-patch --pretty="%h")
#DATE=$(date --rfc-3339="seconds")
#DATE=$(date +"%Y-%m-%d %H:%M:%S%:z")
#DATE=$(date -u -Iseconds)
DATE=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
DATE_HASH=$(date -u +"%Y%m%d%H%M%S")

#VERSION_NAME="TeXworks-${TRAVIS_OS_NAME}-${TW_VERSION}-${DATE_HASH}-git_${GIT_HASH}"

VERSION_NAME="${TW_VERSION}-${DATE_HASH}-git_${GIT_HASH}"

echo "TW_VERSION = ${TW_VERSION}"
echo "GIT_HASH = ${GIT_HASH}"
echo "DATE = ${DATE}"
echo "DATE_HASH = ${DATE_HASH}"

cat > travis-ci/bintray.json << EOF
{
	"package": {
		"name": "Latest-TeXworks-Mac",
		"repo": "generic",
		"subject": "stloeffler"
	},
	"version": {
		"name": "${VERSION_NAME}",
		"released": "${DATE}"
	},
	"files":
	[
		{"includePattern": "${TRAVIS_BUILD_DIR}/build-${TRAVIS_OS_NAME}-qt${QT}/(TeXworks.*\.dmg)", "uploadPattern": "build-${TRAVIS_OS_NAME}-qt${QT}/\$1"}
	],
	
	"publish": true
}
EOF

#		{"includePattern": "${TRAVIS_BUILD_DIR}/build-${TRAVIS_OS_NAME}-qt${QT}/texworks", "uploadPattern": "build-${TRAVIS_OS_NAME}-qt${QT}/texworks"},
#		{"includePattern": "${TRAVIS_BUILD_DIR}/build-${TRAVIS_OS_NAME}-qt${QT}/libTWLuaPlugin.so", "uploadPattern": "build-${TRAVIS_OS_NAME}-qt${QT}/libTWLuaPlugin.so"}
