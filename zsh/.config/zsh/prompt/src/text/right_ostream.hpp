#pragma once

#include "../cli/parser.hpp"
#include "./text.hpp"
#include <cstdint>
#include <cstring>
#include <iostream>
#include <list>
#include <ostream>
#include <string>

namespace text {

class RightCout {
  public:
    RightCout(std::ostream &os) : _os(os) {};

    inline void addNumCharacters(int32_t num) { _num_chars += num; }
    inline void addText(const std::string &text) { _texts.push_back(text); }

    inline RightCout &operator<<(const char c) {
        this->addNumCharacters(1);
        this->addText(std::string(1, c));
        return *this;
    }

    inline RightCout &operator<<(const char *const str) {
        this->addNumCharacters(strlen(str));
        this->addText(str);
        return *this;
    }

    inline RightCout &operator<<(const std::string &str) {
        this->addNumCharacters(str.size());
        this->addText(str);
        return *this;
    }

    inline RightCout &operator<<(std::ostream &(*endl)(std::ostream &)) {
        // If the number of chars is greater than the number of columns, there
        // is no space to add the spaces (right align the text)
        if (_num_chars < cli::args.columns) {
            insert_spaces(cli::args.columns - _num_chars);
        }

        for (auto &text : this->_texts) {
            _os << text;
        }

        _os << endl;
        return *this;
    }

    template <typename T> inline RightCout &operator<<(const T &t) {
        auto string = std::to_string(t);
        return *this << string;
    }

  private:
    std::ostream &_os;
    int32_t _num_chars = 0;
    std::list<std::string> _texts;
};

inline RightCout right_cout(std::cout);

class RightCoutOffset {
  public:
    constexpr RightCoutOffset(int32_t offset) : __offset(offset) {};

    constexpr int32_t Get() const { return __offset; }

  private:
    const int32_t __offset;
};

inline RightCout &operator<<(RightCout &os, const RightCoutOffset &offset) {
    os.addNumCharacters(-offset.Get());

    return os;
}

} // namespace text
