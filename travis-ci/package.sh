#!/usr/bin/env sh

# Exit on errors
set -e

cd "${TRAVIS_BUILD_DIR}"

. travis-ci/defs.sh

print_headline "Packaging ${TARGET_OS}/qt${QT} for deployment"

# Gather information

# GNU extensions for sed are not supported; on Linux, --posix mimicks this behaviour
TW_VERSION=$(sed -ne 's,^#define TEXWORKS_VERSION[[:space:]]"\([0-9.]\{3\,\}\)"$,\1,p' src/TWVersion.h)
echo "TW_VERSION = ${TW_VERSION}"

GIT_HASH=$(git --git-dir=".git" show --no-patch --pretty="%h")
echo "GIT_HASH = ${GIT_HASH}"

GIT_DATE=$(git --git-dir=".git" show --no-patch --pretty="%ci")
echo "GIT_DATE = ${GIT_DATE}"

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

# Start packaging and prepare deployment

export DEPOLY_TEXWORKS=0

if [ "${TARGET_OS}" = "linux" -a "${TRAVIS_OS_NAME}" = "linux" ]; then
	echo "Not packaging for linux"
elif [ "${TARGET_OS}" = "win" -a "${TRAVIS_OS_NAME}" = "linux" ]; then
	if [ ${QT} -eq 4 ]; then
		print_info "Not packaging for ${TARGET_OS}/qt${QT}"
	elif [ ${QT} -eq 5 ]; then
		print_info "Assembling package"
		echo_and_run "mkdir -p \"package-zip/share\""
		echo_and_run "cp \"${BUILDDIR}/TeXworks.exe\" \"package-zip/\""
		echo_and_run "cp COPYING \"package-zip/\""
		echo_and_run "cp -r \"win32/fonts\" \"package-zip/share/\""
		# FIXME: manual (only for tags)
		# FIXME: poppler-dat
		# FIXME: README.txt
		print_info "zipping '${TRAVIS_BUILD_DIR}/TeXworks-${TARGET_OS}-${VERSION_NAME}.zip'"
		echo_and_run "cd package-zip && zip -r \"${TRAVIS_BUILD_DIR}/TeXworks-${TARGET_OS}-${VERSION_NAME}.zip\" *"

		print_info "Preparing travis-ci/bintray.json"

		cat > "${TRAVIS_BUILD_DIR}/travis-ci/bintray.json" << EOF
		{
			"package": {
				"name": "Latest-TeXworks-Win",
				"repo": "generic",
				"subject": "stloeffler"
			},
			"version": {
				"name": "${VERSION_NAME}",
				"released": "${RELEASE_DATE}"
			},
			"files":
			[
				{"includePattern": "${TRAVIS_BUILD_DIR}/TeXworks-${TARGET_OS}-${VERSION_NAME}.zip", "uploadPattern": "TeXworks-${TARGET_OS}-${VERSION_NAME}.zip"}
			],
			"publish": true
		}
EOF
		export DEPLOY_TEXWORKS=1
	else
		print_error "Skipping unsupported combination '${TARGET_OS}/qt${QT}'"
	fi
elif [ "${TARGET_OS}" = "osx" -a "${TRAVIS_OS_NAME}" = "osx" ]; then
	if [ ${QT} -eq 4 ]; then
		print_info "Running CPack"

		cd "${BUILDDIR}" && cpack --verbose

		print_info "Preparing travis-ci/bintray.json"

		cat > "${TRAVIS_BUILD_DIR}/travis-ci/bintray.json" << EOF
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
				{"includePattern": "${TRAVIS_BUILD_DIR}/build-${TRAVIS_OS_NAME}-qt${QT}/(TeXworks.*\.dmg)", "uploadPattern": "TeXworks-${TRAVIS_OS_NAME}-${VERSION_NAME}.dmg"}
			],
			"publish": true
		}
EOF
		export DEPLOY_TEXWORKS=1
	elif [ ${QT} -eq 5 ]; then
		print_info "Not packaging for ${TARGET_OS}/qt${QT}"
	else
		print_error "Skipping unsupported combination '${TARGET_OS}/qt${QT}'"
	fi
else
	print_error "Skipping unsupported host/target combination '${TRAVIS_OS_NAME}/${TARGET_OS}'"
fi

cd "${TRAVIS_BUILD_DIR}"

print_info "Deployment preparation successful"
