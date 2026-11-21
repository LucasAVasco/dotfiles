cmake_minimum_required(VERSION 3.16)

project(
  default-file-manager-dbus
  VERSION 1.0.0
  DESCRIPTION "D-Bus FileManager1 implementation"
  LANGUAGES CXX)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)

add_executable(default-file-manager-dbus src/main.cpp)

target_compile_features(default-file-manager-dbus PRIVATE cxx_std_17)

target_link_libraries(default-file-manager-dbus PRIVATE PkgConfig::GIO)

target_compile_options(default-file-manager-dbus PRIVATE -Wall -Wextra
                                                         -Wpedantic)

install(TARGETS default-file-manager-dbus RUNTIME DESTINATION bin)
