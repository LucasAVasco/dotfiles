#!/bin/env python3


"""Generate vim dochelp files from the user configuration.

Information about how to write vim help files can be found in the ':h help-writing' command.
"""


import subprocess
import pathlib
import re
import os
import shutil
from functools import cached_property

from prompt_toolkit import print_formatted_text, HTML


identation = r'\t'
text_width = 100
tag_prefix = 'mycfg'


class Section:
    separator = '=' * (text_width) + '\n'

    available_types = [
            '_internal',   # Reserved to be used with the main doc file
            'info',        # General information
            'maps',        # Keymaps
            'cmd',         # Commands
            'func',        # Functions
            'opt'          # Options
            ]

    def __init__(self, title: str, type_id: str, tags: list):
        if type_id not in self.available_types:
            raise ValueError(f'Invalid type: {type_id}')

        self._title = title
        self._type_id = type_id
        self._tags = tags
        self.content = []

    @property
    def type_id(self):
        return self._type_id

    @cached_property
    def header(self):
        tags = '*' + '* *'.join(self._tags) + '*'
        separator_size = max(10, text_width - len(self._title) - len(tags))

        return self._title + ' ' * separator_size + tags

    @cached_property
    def index_entry(self):
        tags = '|' + '| |'.join(self._tags) + '|'
        separator_size = max(10, text_width - len(self._title) - len(tags))

        return self._title + ' ' * separator_size + tags

    @property
    def dumped_str(self):
        return self.separator + self.header + '\n' + ''.join(self.content)

    def __repr__(self):
        return f'Section({self.title}, {self.type_id}, {self.tags}, Content length: {len(self.content)})'


def SectionQuery(lines: list):
    def query_title_information(line):
        title = re.split(r'\[', line)[0]
        if type_id := re.match(r'^.*?\[(.*)\].*$', line):
            type_id = type_id.group(1)

        else:
            raise ValueError(f'Invalid line (no type): {line}')

        tags = []
        # Extracts tags (only one per line)
        for tag in re.finditer(r'\*.*?\*', line):
            tag = tag.group(0).replace('*', '')
            tags.append(tag)

        return (title, type_id, tags)

    sections = []
    current_section = None
    for line in lines:
        # Remove the first separator character
        line = re.sub(r'^'+identation, '', line)

        # Section separator
        if re.match(r'^====.*$', line):
            # Warning if the section divider is not the expected size
            size = len(line) - 1
            if size != text_width:
                print_formatted_text(HTML(f'<ansiyellow>WARNING: Section divider is not the expected size ({size} != {text_width})</ansiyellow>'))

            # Changes the section divider
            if current_section is not None: sections.append(current_section)
            current_section = None

        # New section
        elif current_section is None:
            title, type_id, tags = query_title_information(line)
            current_section = Section(title, type_id, tags)

        # Section content
        else:
            current_section.content.append(line)

    # Adds the last section (the last for loop dos not closes the last section)
    if current_section is not None: sections.append(current_section)

    return sections


class InputFile:
    def __init__(self, path: pathlib.Path):
        self._path = path
        self._doc_file_name = tag_prefix + '-' + re.sub(r'\/', '-', str(self._path.parent / self._path.stem)) + '.txt'
        self._sections = []

        with open(self._path, 'r') as file:
            # Get content inside a '--[[ autodoc\n ... \n]]' block
            if re.match(r'--\[\[ autodoc$', file.readline()):
                lines = []
                while line:= file.readline():
                    if re.match(r'\]\]$', line):
                        break
                    else:
                        lines.append(line)

                self._sections += SectionQuery(lines)

    @property
    def doc_name(self):
        return self._doc_file_name

    @cached_property
    def header(self):
        tag = '*' + self._doc_file_name + '*'
        title = self._doc_file_name
        separator_size = max(10, text_width - len(title) - len(tag))

        return title + ' ' * separator_size + tag

    @cached_property
    def index_entry(self):
        tag = '|' + self._doc_file_name + '|'
        title = self._doc_file_name
        separator_size = max(10, text_width - len(title) - len(tag))

        return title + ' ' * separator_size + tag

    @property
    def sections(self):
        return self._sections

    @property
    def has_sections(self):
        return len(self._sections) > 0

    def dump(self):
        # Generates the main file
        with open('doc/' + self._doc_file_name, 'w') as out_file:
            out_file.write(self.header + '\n')
            for section in self._sections:
                out_file.write(section.dumped_str + '\n')


class MainOutputFile:
    def __init__(self, input_files):
        self._path = f'./doc/{tag_prefix}.txt'
        self._input_files = input_files
        self._index_section = Section('Index', '_internal', [tag_prefix + '-index'])
        self._index_section.content.append('\n')
        self._sections = []

    def _create_internal_section(self, title: str, tag: str):
        section = Section(title, '_internal', [tag])
        section.content.append('\n')
        self._sections.append(section)

        return section

    @property
    def _pre_index(self):
        lines = ''
        lines += f'*{tag_prefix}.txt* Documentation of my configuration files\n'

        return lines

    @property
    def _index(self):
        pos_index = self._post_index # The index need to be created after the Post Index, because it 'self._sections' are created by the Post Index

        for section in self._sections:
            self._index_section.content.append(section.index_entry + '\n')

        self._index_section.content.append('\n')

        return self._index_section.dumped_str

    @cached_property
    def _post_index(self):
        # Files
        files_section = self._create_internal_section('Files', tag_prefix + '-files')
        for input_file in self._input_files:
            files_section.content.append(input_file.index_entry + '\n')

        # Maps
        for current_type_id in Section.available_types:
            # Section to hold the specific type (will be dumped in the Main Output File)
            if current_type_id == '_internal': continue  # Skip _internal type
            type_section = self._create_internal_section(current_type_id.capitalize(), tag_prefix + '-' + current_type_id)

            # For each input file, search in each section if the type is the same and add an index to the created type section
            for input_file in self._input_files:
                for file_section in input_file.sections:
                    if file_section.type_id == current_type_id:
                        type_section.content.append(file_section.index_entry + '\n')

            # Removes empty sections. The length is compared with 1 because all sections have at least one entry, a '\n'
            # added by the _create_internal_section() function.
            if len(type_section.content) == 1:
                self._sections.remove(type_section)

        # Dumps the file content as a string
        lines = ''
        for section in self._sections:
            lines += section.dumped_str + '\n'

        # Modeline
        lines += '\n vim:ft=help:norl:'

        return lines

    @cached_property
    def dumped_str(self):
        return self._pre_index + self._index + self._post_index

    def dump(self):
        # Generates the main file
        with open(self._path, 'w') as out_file:
            out_file.write(self.dumped_str)


if __name__ == '__main__':
    # Removes he old doc/ folder and Creates a new one
    if os.path.exists('./doc'):
        shutil.rmtree('./doc')
    os.mkdir('./doc')

    # Reads each file and extracts the sections
    input_files = []
    for path in pathlib.Path('./').rglob('*.lua'):
        print(f'Processing {path}...')
        input_file = InputFile(path)
        if input_file.has_sections:
            input_files.append(input_file)
            input_file.dump()

    # Creates the output file
    output_file = MainOutputFile(input_files)
    output_file.dump()

    # Generates the tag file
    subprocess.run(['nvim', '-c', 'helptags ~/.config/nvim/doc', '+qall'])
