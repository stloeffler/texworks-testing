#!/usr/bin/env sh

# Exit on errors
set -e

. $(dirname $0)/defs.sh

print_headline "Preparing ${TRAVIS_OS_NAME}/qt${QT} for deployment"


# GNU extensions for sed are not supported; on Linux, --posix mimicks this behaviour
TW_VERSION=$(sed -ne 's,^#define TEXWORKS_VERSION[[:space:]]"\([0-9.]\{3\,\}\)"$,\1,p' src/TWVersion.h)
echo "TW_VERSION = ${TW_VERSION}"

GIT_HASH=$(git --git-dir=".git" show --no-patch --pretty="%h")
echo "GIT_HASH = ${GIT_HASH}"

GIT_DATE=$(git --git-dir=".git" show --no-patch --pretty="%ci")
echo "GIT_DATE = ${GIT_DATE}"

#DATE=$(date --rfc-3339="seconds")
#DATE=$(date +"%Y-%m-%d %H:%M:%S%:z")
#DATE=$(date -u -Iseconds)
#DATE=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
DATE_HASH=$(date -u +"%Y%m%d%H%M%S")
echo "DATE_HASH = ${DATE_HASH}"

if [ "${TRAVIS_OS_NAME}" = "linux" ]; then
	RELEASE_DATE=$(date -u +"%Y-%m-%dT%H:%M:%S%z" --date="${GIT_DATE}")
elif [ "${TRAVIS_OS_NAME}" = "osx" ]; then
	RELEASE_DATE=$(date -ujf "%Y-%m-%d %H:%M:%S %z" "${GIT_DATE}" "+%Y-%m-%dT%H:%M:%S%z")
else
	print_error "Unsupported operating system '${TRAVIS_OS_NAME}'"
	exit 1
fi
echo "RELEASE_DATE = ${RELEASE_DATE}"


#VERSION_NAME="TeXworks-${TRAVIS_OS_NAME}-${TW_VERSION}-${DATE_HASH}-git_${GIT_HASH}"
VERSION_NAME="${TW_VERSION}-${DATE_HASH}-git_${GIT_HASH}"
echo "VERSION_NAME = ${VERSION_NAME}"

print_info "Preparing travis-ci/bintray.json"

cat > travis-ci/bintray.json << EOF
{
	"package": {
		"name": "Latest-TeXworks-Mac",
		"repo": "generic",
		"subject": "stloeffler"
	},
	"version": {
		"name": "${VERSION_NAME}",
		"released": "${RELEASE_DATE}"
	},
	"files":
	[
		{"includePattern": "${TRAVIS_BUILD_DIR}/build-${TRAVIS_OS_NAME}-qt${QT}/(TeXworks.*\.dmg)", "uploadPattern": "TeXworks-${TW_VERSION}.dmg"}
	],
	
	"publish": true
}
EOF
#		{"includePattern": "${TRAVIS_BUILD_DIR}/build-${TRAVIS_OS_NAME}-qt${QT}/(TeXworks.*\.dmg)", "uploadPattern": "build-${TRAVIS_OS_NAME}-qt${QT}/\$1"}

#		{"includePattern": "${TRAVIS_BUILD_DIR}/build-${TRAVIS_OS_NAME}-qt${QT}/texworks", "uploadPattern": "build-${TRAVIS_OS_NAME}-qt${QT}/texworks"},
#		{"includePattern": "${TRAVIS_BUILD_DIR}/build-${TRAVIS_OS_NAME}-qt${QT}/libTWLuaPlugin.so", "uploadPattern": "build-${TRAVIS_OS_NAME}-qt${QT}/libTWLuaPlugin.so"}

print_info "Deployment preparation successful"
