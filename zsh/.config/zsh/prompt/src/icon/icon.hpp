#pragma once

#include "../term/info.hpp"
#include "../text/right_ostream.hpp"

#include <ostream>
#include <string>

namespace icon {

class Icon {
  public:
    consteval Icon(const char *const icon) : _icon(icon) {};
    constexpr char const *GetString() const { return _icon; }

  private:
    const char *const _icon;
};

constexpr text::RightCout &operator<<(text::RightCout &os, const Icon &icon) {
    os.addNumCharacters(1);

    // Adds the escape sequence and the icon
    os.addText(term::escape_literal::open_icon_sequence);
    os.addText(icon.GetString());
    os.addText(term::escape_literal::close_icon_sequence);

    return os;
}

constexpr std::ostream &operator<<(std::ostream &os, const Icon &icon) {
    return os << term::escape_literal::open_icon_sequence << icon.GetString()
              << term::escape_literal::close_icon_sequence;
}

const Icon &get_directory_icon(const std::string &directory);

constexpr Icon right_semicircle = Icon("");
constexpr Icon left_semicircle = Icon("");

constexpr Icon right_triangle = Icon("");
constexpr Icon left_triangle = Icon("");

constexpr Icon bottom_right_triangle = Icon("");
constexpr Icon bottom_left_triangle = Icon("");
constexpr Icon top_right_triangle = Icon("");
constexpr Icon top_left_triangle = Icon("");

constexpr Icon right_triangle_inv = Icon("");
constexpr Icon left_triangle_inv = Icon("");
constexpr Icon right_triangle_inv_separated = Icon("");
constexpr Icon left_triangle_inv_separated = Icon("");

constexpr Icon right_semicircle_line = Icon("");
constexpr Icon left_semicircle_line = Icon("");

constexpr Icon right_triangle_line = Icon("");
constexpr Icon left_triangle_line = Icon("");

constexpr Icon line_45 = Icon("");
constexpr Icon line_135 = Icon("");

} // namespace icon
