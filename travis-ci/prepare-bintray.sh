#!/usr/bin/env sh

TW_VERSION=$(sed -ne 's,^#define TEXWORKS_VERSION\s"\?\([0-9.]\+\)"\?$,\1,p' src/TWVersion.h)
GIT_HASH=$(git --git-dir=".git" show --no-patch --pretty="%h")
DATE=$(date --rfc-3339="seconds")
DATE_HASH=$(date +"%Y%m%d%H%M%d")

PACKAGE_NAME="TeXworks-mac-${TW_VERSION}-${DATE_HASH}-git_${GIT_HASH}.tar.bz2"

cat > travis-ci/bintray.desc << EOF
{
	/* Bintray package information.
	   In case the package already exists on Bintray, only the name, repo and subject
	   fields are mandatory. */
	"package": {
		"name": "TeXworks-latest", // Bintray package name
		"repo": "generic", // Bintray repository name
		"subject": "stloeffler" // Bintray subject (user or organization)
	}
	/* Package version information.
	   In case the version already exists on Bintray, only the name fields is mandatory. */
	"version": {
		"name": "${PACKAGE_NAME}",
		"released": "${DATE}"
	},
	/* Configure the files you would like to upload to Bintray and their upload path.
	You can define one or more groups of patterns.
	Each group contains three patterns:

	includePattern: Pattern in the form of Ruby regular expression, indicating the path of files to be uploaded to Bintray.
	excludePattern: Optional. Pattern in the form of Ruby regular expression, indicating the path of files to be removed from the list of files specified by the includePattern.
	uploadPattern: Upload path on Bintray. The path can contain symbols in the form of $1, $2,... that are replaced with capturing groups defined in the include pattern.

	In the example below, the following files are uploaded,
	1. All gem files located under build/bin/ (including sub directories),
	except for files under a the do-not-deploy directory.
	The files will be uploaded to Bintray under the gems folder.
	2. All files under build/docs. The files will be uploaded to Bintray under the docs folder.

	Note: Regular expressions defined as part of the includePattern property must be wrapped with brackets. */

	"files":
	[
		{"includePattern": "build/.*", "uploadPattern": "files"}
	],
	
	"publish": true
}
EOF
