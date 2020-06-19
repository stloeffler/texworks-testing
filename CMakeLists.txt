cmake_minimum_required(VERSION 3.1)
project(mac-sysinfo)

find_package(Qt5 COMPONENTS Core)

add_executable(mac-sysinfo mac-sysinfo.cpp)
target_link_libraries(mac-sysinfo Qt5::Core)
