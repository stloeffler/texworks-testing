cmake_minimum_required(VERSION 3.1)
project(mac-sysinfo)

find_package(Qt5 COMPONENTS Core)

if (APPLE)
	set(GUI_TYPE MACOSX_BUNDLE)
	set(ADDITIONAL_LIBS "-framework CoreServices")
endif (APPLE)

add_executable(mac-sysinfo ${GUI_TYPE} mac-sysinfo.cpp)
target_link_libraries(mac-sysinfo Qt5::Core ${ADDITIONAL_LIBS})
