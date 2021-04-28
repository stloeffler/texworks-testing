# MACOSX_DEPLOYMENT_TARGET=10.14 cmake .. -DCMAKE_PREFIX_PATH="/opt/qt/5.15.2/clang_64"


# Tw:
# MACOSX_DEPLOYMENT_TARGET=10.14 cmake -DCMAKE_PREFIX_PATH=/opt/qt/5.15.2/clang_64 -D CMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE ..
# make -j
# MACOSX_DEPLOYMENT_TARGET=10.14 cpack -V

cmake_minimum_required(VERSION 3.6)
# 3.6 is required for GIT_SHALLOW

project(TeXworksDependencyInstall)

find_package(Qt5 REQUIRED COMPONENTS Widgets)

# Adapted from https://github.com/Homebrew/homebrew-core/blob/e2c833d326c45d9aaf4e26af6dd8b2f31564dc04/Formula/fontconfig.rb
file(GLOB _font_dirs /System/Library/Assets*/com_apple_MobileAsset_Font*)
list(INSERT _font_dirs 0 /System/Library/Fonts /Library/Fonts ~/Library/Fonts)
string(REPLACE ";" "," _font_dirs "${_font_dirs}")

set(CONFIGURE_ENV CFLAGS=-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET} CXXFLAGS=-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET})

set(CMAKE_ARGS -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH} -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE -DCMAKE_MACOSX_RPATH=TRUE)

include(ExternalProject)


# FIXME: ld: warning: dylib (/usr/local/lib/libintl.dylib) was built for newer macOS version (10.15) than being linked (10.14)
ExternalProject_Add(hunspell
	GIT_REPOSITORY https://github.com/hunspell/hunspell.git
	GIT_TAG v1.7.0
	GIT_SHALLOW TRUE
	CONFIGURE_COMMAND autoreconf -vfi && ${CONFIGURE_ENV} ./configure
	BUILD_IN_SOURCE TRUE
)

ExternalProject_Add(libpng
	GIT_REPOSITORY git://git.code.sf.net/p/libpng/code
	GIT_TAG v1.6.37
	CMAKE_ARGS ${CMAKE_ARGS}
)

# TODO: harfbuzz?
ExternalProject_Add(freetype
	GIT_REPOSITORY https://gitlab.freedesktop.org/freetype/freetype.git
	GIT_TAG VER-2-10-4
	GIT_SHALLOW TRUE
	CMAKE_ARGS ${CMAKE_ARGS} -DFT_WITH_HARFBUZZ=FALSE -DBUILD_SHARED_LIBS=TRUE
	PATCH_COMMAND patch --forward -p1 < ${CMAKE_CURRENT_LIST_DIR}/freetype-bz2.patch || test \\\$? -le 1
	DEPENDS libpng
)

ExternalProject_Add(fontconfig
	GIT_REPOSITORY https://gitlab.freedesktop.org/fontconfig/fontconfig.git
	GIT_TAG 2.13.1
	CONFIGURE_COMMAND autoreconf -vfi && ${CONFIGURE_ENV} ./configure --with-add-fonts="${_font_dirs}"
	BUILD_IN_SOURCE TRUE
	DEPENDS freetype
)

ExternalProject_Add(libjpeg
	URL https://ijg.org/files/jpegsrc.v9d.tar.gz
	URL_HASH SHA256=6c434a3be59f8f62425b2e3c077e785c9ce30ee5874ea1c270e843f273ba71ee
	CONFIGURE_COMMAND ${CONFIGURE_ENV} ./configure
	BUILD_IN_SOURCE TRUE
)

# jbig? Lzma?
ExternalProject_Add(libtiff
	GIT_REPOSITORY https://gitlab.com/libtiff/libtiff.git
	GIT_TAG v4.3.0
	GIT_SHALLOW TRUE
	CMAKE_ARGS ${CMAKE_ARGS}
	DEPENDS libjpeg
)

ExternalProject_Add(libopenjpeg
	GIT_REPOSITORY https://github.com/uclouvain/openjpeg.git
	GIT_TAG v2.4.0
	GIT_SHALLOW TRUE
	CMAKE_ARGS ${CMAKE_ARGS}
	DEPENDS libtiff
)

ExternalProject_Add(lcms2
	GIT_REPOSITORY https://github.com/mm2/Little-CMS.git
	GIT_TAG lcms2.12
	GIT_SHALLOW TRUE
	CONFIGURE_COMMAND ${CONFIGURE_ENV} ./configure
	BUILD_IN_SOURCE TRUE
)

# cairo?
ExternalProject_Add(poppler
	GIT_REPOSITORY https://anongit.freedesktop.org/git/poppler/poppler.git
	GIT_TAG poppler-21.04.0
	GIT_SHALLOW TRUE
	CMAKE_ARGS ${CMAKE_ARGS} -DENABLE_CPP=FALSE -DENABLE_UNSTABLE_API_ABI_HEADERS=TRUE
	DEPENDS fontconfig freetype lcms2 libjpeg libopenjpeg libpng libtiff
)

ExternalProject_Add(poppler-data
	URL https://poppler.freedesktop.org/poppler-data-0.4.10.tar.gz
	URL_HASH SHA256=6e2fcef66ec8c44625f94292ccf8af9f1d918b410d5aa69c274ce67387967b30
)

ExternalProject_Add(lua
	URL http://www.lua.org/ftp/lua-5.4.3.tar.gz
	URL_HASH SHA1=1dda2ef23a9828492b4595c0197766de6e784bc7
	CONFIGURE_COMMAND ""
	BUILD_COMMAND make MYCFLAGS="-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}"
	BUILD_IN_SOURCE TRUE
)
