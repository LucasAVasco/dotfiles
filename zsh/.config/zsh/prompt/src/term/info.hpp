#pragma once

#include <cstdint>
#include <iostream>

#include "../cli/parser.hpp"

namespace term {

inline void repeat_escape(const char *const escape_code, const uint8_t times) {
    for (uint8_t count = times; count > 0; --count) {
        std::cout << escape_code;
    }
}

inline void put_escape(const char *const escape_code) {
    std::cout << escape_code;
}

inline uint32_t getNumColumns() { return cli::args.columns; }

namespace escape_literal {

constexpr char open_sequence[] = "%{";
constexpr char close_sequence[] = "%}";
constexpr char open_icon_sequence[] = "%1{";
constexpr char close_icon_sequence[] = "%}";

inline void open() { std::cout << open_sequence; }

inline void close() { std::cout << close_sequence; }

} // namespace escape_literal

} // namespace term
