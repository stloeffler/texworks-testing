cmake_minimum_required(VERSION 3.1)
project(mac-env)

find_package(Qt5 COMPONENTS Widgets)

if (APPLE)
  set(GUI_TYPE MACOSX_BUNDLE)
endif ()

add_executable(mac-env ${GUI_TYPE} mac-env.cpp)
target_link_libraries(mac-env Qt5::Widgets)
