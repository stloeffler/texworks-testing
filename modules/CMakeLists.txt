
SET(MODULE_INCLUDE_DIRS)

message("1: QTPDF_VIEWER = ${QTPDF_VIEWER}")

SET(QTPDF_LIB_TYPE STATIC)
SET(QTPDF_VIEWER OFF)

message("1: QTPDF_VIEWER = ${QTPDF_VIEWER}")
ADD_SUBDIRECTORY(QtPDF)

message("1: QTPDF_VIEWER = ${QTPDF_VIEWER}")

# We DO NOT include the synctex subdirectory here as that is handled entirely by
# FindSynctex.cmake
