cmake_minimum_required(VERSION 3.5)

project(Measure LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
list(APPEND QML_DIRS "${CMAKE_SOURCE_DIR}") #qmldir路径
set(QML_IMPORT_PATH "${QML_DIRS}" CACHE STRING "qml import paths")
file(GLOB SRC_FILES "${SRC_DIR}/*.cpp")
file(GLOB INC_FILES "${SRC_DIR}/*.h")
# 将源文件和头文件添加到项目中
foreach(SRC_FILE ${SRC_FILES})
    set_property(SOURCE ${SRC_FILE} PROPERTY LANGUAGE CXX)
    list(APPEND PROJECT_SOURCES ${SRC_FILE})
endforeach()

foreach(INC_FILE ${INC_FILES})
    list(APPEND PROJECT_HEADERS ${INC_FILE})
endforeach()
#include(FetchContent)
#FetchContent_Declare(
#  cpr
#  GIT_REPOSITORY https://github.com/libcpr/cpr.git
#  GIT_TAG 1b03deba3a84ba8b765b2f57ab05da825326aec9  # 你可以根据需要更改为特定的tag或branch
#)
#FetchContent_MakeAvailable(cpr)
# QtCreator supports the following variables for Android, which are identical to qmake Android variables.
# Check http://doc.qt.io/qt-5/deployment-android.html for more information.
# They need to be set before the find_package(Qt5 ...) call.

#if(ANDROID)
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
#    if (ANDROID_ABI STREQUAL "armeabi-v7a")
#        set(ANDROID_EXTRA_LIBS
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libcrypto.so7

#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libssl.so)
#    endif()
#endif()

find_package(Qt5 COMPONENTS Core Quick REQUIRED)
find_package(Qt5 REQUIRED COMPONENTS Network)
# find_package(Qt6 6.4 REQUIRED COMPONENTS Quick)
# find_package(Qt6 REQUIRED COMPONENTS Network)
if(ANDROID)
    add_library(Measure SHARED
      main.cpp
      qml.qrc
      ${PROJECT_SOURCES} ${PROJECT_HEADERS}
    )
else()
    add_executable(Measure
      main.cpp
      qml.qrc
      ${PROJECT_SOURCES} ${PROJECT_HEADERS}
    )
endif()

target_compile_definitions(Measure
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(Measure
  PRIVATE Qt5::Core Qt5::Quick)
target_link_libraries(Measure PRIVATE Qt5::Network)
#target_link_libraries(Measure PRIVATE cpr::cpr)

