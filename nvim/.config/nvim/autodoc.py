#!/bin/env python3


"""Generate vim dochelp files from the user configuration.

Information about how to write vim help files can be found in the ":h help-writing"
command.
"""


from __future__ import annotations

import pathlib
import re
import shutil
import subprocess
from functools import cached_property

indentation = r"\t"
text_width = 100
tag_prefix = "mycfg"
model_line = "\n vim:ft=help:norl:"


class Section:
    """One section in a autodoc header."""

    separator = "=" * (text_width) + "\n"

    available_types = (
        "_internal",   # Reserved to be used with the main doc file
        "info",        # General information
        "maps",        # Keymaps
        "cmd",         # Commands
        "func",        # Functions
        "opt",         # Options
        )

    def __init__(self, title: str, type_id: str, tags: list[str]) -> None:
        """Create a new "Section" object.

        Parameters
        ----------
        title: str
            Title of the section.

        type_id: str
            Type of the section.

        tags: list
            List of tags of the section.

        """
        if type_id not in self.available_types:
            msg = f"Invalid type: {type_id}"
            raise ValueError(msg)

        self._title = title
        self._type_id = type_id
        self._tags = tags
        self.content: list[str] = []

    @property
    def type_id(self) -> str:
        """Type identifier of the Section."""
        return self._type_id

    @cached_property
    def header(self) -> str:
        """Header of the section."""
        tags = "*" + "* *".join(self._tags) + "*"
        separator_size = max(10, text_width - len(self._title) - len(tags))

        return self._title + " " * separator_size + tags

    @cached_property
    def index_entry(self) -> str:
        """Text of a index entry that points to this section."""
        tags = "|" + "| |".join(self._tags) + "|"
        separator_size = max(10, text_width - len(self._title) - len(tags))

        return self._title + " " * separator_size + tags

    @property
    def dumped_str(self) -> str:
        """Documentation of this section."""
        return self.separator + self.header + "\n" + "".join(self.content)

    def __repr__(self) -> str:
        """Represent the current section as a string."""
        return (
            f"Section({self._title}, {self.type_id}, {self._tags}, Content length:"
            f"{len(self.content)})"
        )


def section_query(lines: list[str]) -> list[Section]:
    """Return all sections of a file."""

    def query_title_information(line: str) -> tuple[str, str, list[str]]:
        """Query relevant information about the section by its first line.

        Parameters
        ----------
        line: str
            First line of the section.

        Return
        ------
        title: str
            Title of the section.

        type_id: str
            Type identifier of the section.

        tags: list[str]
            List of tags of the section.

        """
        title = re.split(r"\[", line)[0]
        type_id = ""
        if match := re.match(r"^.*?\[(.*)\].*$", line):
            type_id = match.group(1)

        else:
            msg = f"Invalid line (no type): {line}"
            raise ValueError(msg)

        tags = []
        # Extracts tags (only one per line)
        for match in re.finditer(r"\*.*?\*", line):
            tag = match.group(0).replace("*", "")
            tags.append(tag)

        return (title, type_id, tags)

    sections: list[Section] = []
    current_section = None
    for line in lines:
        # Remove the first separator character
        formatted_line = re.sub(r"^"+indentation, "", line)

        # Section separator
        if re.match(r"^====.*$", formatted_line):
            # Warning if the section divider is not the expected size
            size = len(formatted_line) - 1
            if size != text_width:
                print("\033[1;33mWARNING: Section divider is not the expected size"  # noqa: T201
                    f"({size} != {text_width}) \033[0m")

            # Changes the section divider
            if current_section is not None:
                sections.append(current_section)

            current_section = None

        # New section
        elif current_section is None:
            title, type_id, tags = query_title_information(formatted_line)
            current_section = Section(title, type_id, tags)

        # Section content
        else:
            current_section.content.append(formatted_line)

    # Adds the last section (the last for loop dos not closes the last section)
    if current_section is not None:
        sections.append(current_section)

    return sections


class InputFile:
    """Class to manage a input file and its sections."""

    def __init__(self, path: pathlib.Path) -> None:
        """Create a new "InputFile" object.

        Parameters
        ----------
        path: pathlib.Path
            Path of the input file.

        """
        self._path = path
        self._doc_file_name = tag_prefix + "-" + \
            re.sub(r"\/", "-", str(self._path.parent / self._path.stem)) + ".txt"
        self._sections: list[Section] = []

        with pathlib.Path(self._path).open() as file:
            # Get content inside a "--[[ autodoc\n ... \n]]" block
            if re.match(r"--\[\[ autodoc$", file.readline()):
                lines = []
                while line:= file.readline():
                    if re.match(r"\]\]$", line):
                        break

                    lines.append(line)

                self._sections += section_query(lines)

    @property
    def doc_name(self) -> str:
        """Name of the documentation file (vimdoc)."""
        return self._doc_file_name

    @cached_property
    def header(self) -> str:
        """Header of the documentation file."""
        tag = "*" + self._doc_file_name + "*"
        title = self._doc_file_name
        separator_size = max(10, text_width - len(title) - len(tag))

        return title + " " * separator_size + tag

    @cached_property
    def index_entry(self) -> str:
        """Index entry that points to the documentation file."""
        tag = "|" + self._doc_file_name + "|"
        title = self._doc_file_name
        separator_size = max(10, text_width - len(title) - len(tag))

        return title + " " * separator_size + tag

    @property
    def sections(self) -> list[Section]:
        """List of sections available in the file.."""
        return self._sections

    @property
    def has_sections(self) -> bool:
        """If the input file has, at least, one section."""
        return len(self._sections) > 0

    def dump(self) -> None:
        """Generate the documentation (vimdoc) of the file and save it to its file."""
        # Generates the main file
        with pathlib.Path("doc/" + self._doc_file_name).open("w") as out_file:
            out_file.write(self.header + "\n")
            for section in self._sections:
                out_file.write(section.dumped_str + "\n")
            out_file.write(model_line)


class MainOutputFile:
    """Main documentation file.

    This file points to all others documentation files and sections.
    """

    def __init__(self, input_files: list[InputFile]) -> None:
        """Create a new object to manage the main documentation file.

        Parameters
        ----------
        input_files: list[InputFile]
            List of input files that will be used to generate the documentation.

        """
        self._path = f"./doc/{tag_prefix}.txt"
        self._input_files: list[InputFile] = input_files
        self._index_section = Section("Index", "_internal", [tag_prefix + "-index"])
        self._index_section.content.append("\n")
        self._sections: list[Section] = []

    def _create_internal_section(self, title: str, tag: str) -> Section:
        """Create a section of the output file."""
        section = Section(title, "_internal", [tag])
        section.content.append("\n")
        self._sections.append(section)

        return section

    @property
    def _pre_index(self) -> str:
        """Text of the output file before the Index entry."""
        lines = ""
        lines += f"*{tag_prefix}.txt* Documentation of my configuration files\n"

        return lines

    @property
    def _index(self) -> str:
        """Index of the main output file."""
        # The index need to be created after the Post Index, because it "self._sections"
        # are created by the Post Index
        pos_index = self._post_index  # noqa: F841

        for section in self._sections:
            self._index_section.content.append(section.index_entry + "\n")

        self._index_section.content.append("\n")

        return self._index_section.dumped_str

    @cached_property
    def _post_index(self) -> str:
        """Text to be placed after the index."""
        # Files
        files_section = self._create_internal_section("Files", tag_prefix + "-files")
        for input_file in self._input_files:
            files_section.content.append(input_file.index_entry + "\n")

        # Maps
        for current_type_id in Section.available_types:
            # Section to hold the specific type (will be dumped in the Main Output File)
            if current_type_id == "_internal":
                continue  # Skip _internal type

            type_section = self._create_internal_section(
                current_type_id.capitalize(), tag_prefix + "-" + current_type_id)

            # For each input file, search in each section if the type is the same and
            # add an index to the created type section
            for input_file in self._input_files:
                for file_section in input_file.sections:
                    if file_section.type_id == current_type_id:
                        type_section.content.append(file_section.index_entry + "\n")

            # Removes empty sections. The length is compared with 1 because all sections
            # have at least one entry, a "\n" added by the _create_internal_section()
            # function.
            if len(type_section.content) == 1:
                self._sections.remove(type_section)

        # Dumps the file content as a string
        lines = ""
        for section in self._sections:
            lines += section.dumped_str + "\n"

        # Modeline
        lines += model_line

        return lines

    @cached_property
    def dumped_str(self) -> str:
        """Content of the main output file."""
        return self._pre_index + self._index + self._post_index

    def dump(self) -> None:
        """Write the content of the main output file in its destination file."""
        # Generates the main file
        with pathlib.Path(self._path).open("w") as out_file:
            out_file.write(self.dumped_str)


if __name__ == "__main__":
    # Removes he old doc/ folder and Creates a new one
    doc_folder = pathlib.Path("./doc")
    if doc_folder.exists():
        shutil.rmtree("./doc")
    doc_folder.mkdir()

    # Reads each file and extracts the sections
    input_files = []
    for path in pathlib.Path("./").rglob("*.lua"):
        print(f"Processing {path}...")  # noqa: T201
        input_file = InputFile(path)
        if input_file.has_sections:
            input_files.append(input_file)
            input_file.dump()

    # Creates the output file
    output_file = MainOutputFile(input_files)
    output_file.dump()

    # Generates the tag file
    subprocess.run(  # noqa: S603
        ["/bin/nvim", "-c", "helptags ~/.config/nvim/doc", "+qall"],
        check=True, shell=False)
