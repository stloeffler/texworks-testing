cmake_minimum_required(VERSION 3.1)
project(mac-sleep)

find_package(Qt5 COMPONENTS Core Test)

add_executable(mac-sleep mac-sleep.cpp)
target_link_libraries(mac-sleep Qt5::Core Qt5::Test)
