cmake_minimum_required(VERSION 3.1)
project(test)

find_package(Qt5 REQUIRED COMPONENTS Core Widgets)

add_executable(test test.cpp)
target_link_libraries(test Qt5::Core Qt5::Widgets)
