cmake_minimum_required(VERSION 3.1)
project(mac-timing)

find_package(Qt5 COMPONENTS Core Test)

add_executable(mac-timing mac-timing.cpp)
target_link_libraries(mac-timing Qt5::Core Qt5::Test)
