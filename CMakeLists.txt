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
file(GLOB SRC_ICON_FILES "${SRC_DIR}/*.rc")
file(GLOB INC_FILES "${SRC_DIR}/*.h")

#[[
set(CPP_EasyQtSql "${CMAKE_CURRENT_SOURCE_DIR}/EasyQtSql/*.cpp")
set(H_EasyQtSql "${CMAKE_CURRENT_SOURCE_DIR}/EasyQtSql/*.h")
set(H_SRC_EasyQtSql "${CMAKE_CURRENT_SOURCE_DIR}/EasyQtSql/src/*.h")
file(GLOB CPP_EasyQtSql "EasyQtSql/*.cpp")
file(GLOB H_EasyQtSql "${H_EasyQtSql}/*.h")
file(GLOB H_SRC_EasyQtSql "${H_SRC_EasyQtSql}/*.h")
]]

# 将源文件和头文件添加到项目中
foreach(SRC_FILE ${SRC_FILES})
    set_property(SOURCE ${SRC_FILE} PROPERTY LANGUAGE CXX)
    list(APPEND PROJECT_SOURCES ${SRC_FILE})
endforeach()

foreach(INC_FILE ${INC_FILES})
    list(APPEND PROJECT_HEADERS ${INC_FILE})
endforeach()

find_package(Qt5 COMPONENTS Core Quick Sql REQUIRED)
find_package(Qt5 REQUIRED COMPONENTS Network)

#include_directories(C:/Program Files/zlib/include)
#find_library(QUAZIP_LIBRARY NAMES zlib PATHS C:/Program Files/zlib/lib)
#if(NOT QUAZIP_LIBRARY)
#    message(FATAL_ERROR "Could not find zlib library")
#endif()

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
      icon.rc
      qml.qrc
      ${PROJECT_SOURCES} ${PROJECT_HEADERS}
      #${CPP_EasyQtSql} ${H_EasyQtSql} ${H_SRC_EasyQtSql}
    )
endif()

target_compile_definitions(Measure
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(Measure
  PRIVATE Qt5::Core Qt5::Quick Qt5::Sql)
target_link_libraries(Measure PRIVATE Qt5::Network)
#target_link_libraries(Measure PRIVATE cpr::cpr)

