#!/usr/bin/env sh

# Exit on errors
set -e

. $(dirname $0)/defs.sh

print_headline "Getting dependencies for building for ${TARGET_OS}/qt${QT} on ${TRAVIS_OS_NAME}"

if [ "${TARGET_OS}" = "linux" -a "${TRAVIS_OS_NAME}" = "linux" ]; then
	print_info "Updating apt cache"
	sudo apt-get -qq update
	if [ $QT -eq 4 ]; then
		print_info "Installing packages: libqt4-dev zlib1g-dev libhunspell-dev libpoppler-qt4-dev liblua5.2-dev"
		sudo apt-get -qq update && sudo apt-get install -y libqt4-dev zlib1g-dev libhunspell-dev libpoppler-qt4-dev liblua5.2-dev
	elif [ $QT -eq 5 ]; then
		print_info "Installing packages: qtbase5-dev qtscript5-dev qttools5-dev zlib1g-dev libhunspell-dev libpoppler-qt5-dev libpoppler-private-dev liblua5.2-dev"
		sudo apt-get install -y qtbase5-dev qtscript5-dev qttools5-dev zlib1g-dev libhunspell-dev libpoppler-qt5-dev libpoppler-private-dev liblua5.2-dev;
	else
		print_error "Unsupported Qt version '${QT}'"
		exit 1
	fi
elif [ "${TARGET_OS}" = "win" -a "${TRAVIS_OS_NAME}" = "linux" ]; then
	print_info "Adding pkg.mxe.cc apt repo"
	echo "deb http://pkg.mxe.cc/repos/apt/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mxeapt.list > /dev/null
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D43A795B73B16ABE9643FE1AFD8FFF16DB45C6AB
	print_info "Updating apt cache"
	sudo apt-get -qq update
	print_info "Installing packages: curl freetype gcc hunspell jpeg libpng lcms1 pkg-config qtbase qtscript qttools tiff"
	sudo apt-get install -y mxe-i686-w64-mingw32.static-curl mxe-i686-w64-mingw32.static-freetype mxe-i686-w64-mingw32.static-gcc mxe-i686-w64-mingw32.static-hunspell mxe-i686-w64-mingw32.static-jpeg mxe-i686-w64-mingw32.static-libpng mxe-i686-w64-mingw32.static-lcms1 mxe-i686-w64-mingw32.static-pkgconf mxe-i686-w64-mingw32.static-qt mxe-i686-w64-mingw32.static-qtbase mxe-i686-w64-mingw32.static-qtscript mxe-i686-w64-mingw32.static-qttools mxe-i686-w64-mingw32.static-tiff
	print_info "Building poppler"
#	cd travis-ci
	MXEDIR="/usr/lib/mxe"
	MXE_TARGETS="i686-w64-mingw32.static"
#	env PATH="${MXEDIR}/usr/bin:${MXEDIR}/usr/${MXETARGET}/qt5/bin:$PATH" PREFIX="${MXEDIR}/usr" TARGET="${MXETARGET}" JOBS=2 make -f build-poppler-mxe.mk
	cd "${MXEDIR}"
	# make sure dependencies are not rebuilt
#	echo "JOBS := 2\nMXE_TARGETS := i686-w64-mingw32.static" | sudo tee "settings.mk"
#	find . -iname 'installed/*'
	sudo make qt5 --touch
	sudo make poppler
elif [ "${TARGET_OS}" = "osx" -a "${TRAVIS_OS_NAME}" = "osx" ]; then
	print_info "Updating homebrew"
	brew update > brew_update.log || { print_error "Updating homebrew failed"; cat brew_update.log; exit 1; }
	if [ $QT -eq 4 ]; then
		print_info "Brewing packages: qt4 poppler hunspell lua"
		brew install qt4
		brew install "${TRAVIS_BUILD_DIR}/CMake/packaging/mac/poppler.rb" --with-qt --enable-xpdf-headers
	elif [ $QT -eq 5 ]; then
		print_info "Brewing packages: qt5 poppler hunspell lua"
		brew install qt5
		brew install "${TRAVIS_BUILD_DIR}/CMake/packaging/mac/poppler.rb" --with-qt5 --enable-xpdf-headers
	else
		print_error "Unsupported Qt version '${QT}'"
		exit 1
	fi
	brew install hunspell
	brew install lua;
else
	print_error "Unsupported host/target combination '${TRAVIS_OS_NAME}/${TARGET_OS}'"
	exit 1
fi

print_info "Successfully set up dependencies"
