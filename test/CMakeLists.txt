cmake_minimum_required(VERSION 3.1)
project(test)

#find_package(Qt5 REQUIRED COMPONENTS Core Widgets)
find_package(Qt5 REQUIRED COMPONENTS Core)

add_executable(tst test.cpp)
#target_link_libraries(tst Qt5::Core Qt5::Widgets)
target_link_libraries(tst Qt5::Core)
