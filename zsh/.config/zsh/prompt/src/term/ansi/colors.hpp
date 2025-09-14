#pragma once

#include "../../shell/escapes.hpp"
#include "../../text/right_ostream.hpp"

#include <charconv>
#include <cstdint>
#include <ostream>

namespace term::ansi {

namespace colors {

enum class modifier : uint8_t {
    normal = 0,
    bold = 1,
    faint = 2,
    italic = 3,
    underline = 4,
    blink = 5,
    fastblink = 6,
    reverse = 7,
    hide = 8,
    strike = 9,
};

class ModEscape {
  public:
    char value[9];

    consteval ModEscape(const modifier mod) : value("%{\e[0m") {
        value[4] = static_cast<uint8_t>(mod) + '0';
        value[6] = '%';
        value[7] = '}';
    };
};

inline std::ostream &operator<<(std::ostream &os,
                                const ModEscape &escape_color) {
    return os << escape_color.value;
}

class EscapeColor {
  public:
    char value[30];

    consteval EscapeColor(const char *rgb, const char ground = 'f')
        : value("%{\e[38;2") {
        if (ground != 'f' && ground != 'b') {
            throw std::invalid_argument("Invalid 'ground' argument.");
        }

        auto hexchar2uint = [](uint8_t hex) {
            if (hex <= '9')
                return hex - '0';
            else if (hex <= 'Z') {
                return hex - 'A' + 10;
            } else { // `hex` between 'a' and 'z'
                return hex - 'a' + 10;
            }
        };

        auto get_color_from_rgb = [rgb, hexchar2uint](uint8_t index) {
            char color[3] = "00";
            color[0] = rgb[1 + 2 * index];
            color[1] = rgb[2 + 2 * index];
            return hexchar2uint(color[0]) * 16 + hexchar2uint(color[1]);
        };
        uint8_t r = get_color_from_rgb(0), g = get_color_from_rgb(1),
                b = get_color_from_rgb(2);

        // Initial escape sequence
        char *end_of_string =
            &(this->value[8]); // End of the color escape. (character after the
                               // last inserted)

        // Background color
        if (ground == 'b') {
            this->value[4] = '4';
        }

        // Append ":<color>" to the `this->value`
        auto add_color = [var = this, end_of_string,
                          save_end_of_string =
                              &end_of_string](uint8_t color) mutable {
            *end_of_string = ';';
            ++end_of_string;
            auto res = std::to_chars(end_of_string, end_of_string + 3, color);
            end_of_string = res.ptr;
            *save_end_of_string = end_of_string;
        };

        // Append each RGB color
        add_color(r);
        add_color(g);
        add_color(b);

        // End of the escape sequence
        *(end_of_string++) = 'm';
        *(end_of_string++) = '%';
        *(end_of_string++) = '}';
        *(end_of_string) = '\0';
    };
};

inline text::RightCout &operator<<(text::RightCout &os,
                                   const EscapeColor &escape_color) {
    os.addText(escape_color.value);
    return os;
}

inline std::ostream &operator<<(std::ostream &os,
                                const EscapeColor &escape_color) {
    return os << escape_color.value;
}

constexpr char reset_fg[] = ESCAPED("\e[39m");
constexpr char reset_bg[] = ESCAPED("\e[49m");

} // namespace colors

namespace style {

constexpr char normal[] = ESCAPED("\e[0m");
constexpr char bold[] = ESCAPED("\e[1m");
constexpr char italic[] = ESCAPED("\e[3m");

} // namespace style
//
} // namespace term::ansi
