cmake_minimum_required(VERSION 3.29.6)
set(CMAKE_CXX_STANDARD 23)

project(CustomPrompt)

add_executable(
  left
  ./src/left.cpp
  ./src/icon/icon.cpp
  ./src/text/text.cpp
  ./src/env/env.cpp
  ./src/dir/working.cpp
  ./src/git/info.cpp
  ./src/cli/parser.cpp)

add_executable(override_last_prompt ./src/override_last_prompt.cpp
                                    ./src/cli/parser.cpp)
