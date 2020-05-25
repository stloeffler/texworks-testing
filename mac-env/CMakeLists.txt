cmake_minimum_required(VERSION 3.1)
project(mac-env)

find_package(Qt5 COMPONENTS Widgets)

add_executable(mac-env mac-env.cpp)
target_link_libraries(mac-env Qt5::Widgets)
