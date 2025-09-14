#ifndef ESCAPES_HPP
#define ESCAPES_HPP

#define OPEN_ESCAPE "%{"
#define CLOSE_ESCAPE "%}"
#define ESCAPED(text) OPEN_ESCAPE text CLOSE_ESCAPE
#define ESCAPED_SPACED(text) " " ESCAPED(text) " "

#define OPEN_ICON_ESCAPE "%1{"
#define CLOSE_ICON_ESCAPE "%}"
#define ESCAPED_ICON(text) OPEN_ICON_ESCAPE text CLOSE_ICON_ESCAPE
#define ESCAPED_ICON_SPACED(text) " " ESCAPED_ICON(text) " "

#endif // end of ESCAPES_HPP
