; extends

; Inject RST into module docstrings
(module
  (expression_statement
    (string
      (string_start)
      (string_content) @injection.content
      (string_end)) @_docstring)

  (#match? @_docstring "^\"\"\"")
  (#set! injection.language "rst")
)

; Inject RST into function docstrings
(function_definition
  body: (block
    (expression_statement
      (string
        (string_start)
        (string_content) @injection.dedented-content
        (string_end)) @_docstring)
    )

  (#match? @_docstring "^\"\"\"")
  (#set! injection.language "rst")
  (#set! injection.ignore-first-line-indentation 1)
)

; Inject RST into class docstrings
(class_definition
  body: (block
    (expression_statement
      (string
        (string_start)
        (string_content) @injection.dedented-content
        (string_end)) @_docstring)
    )

  (#match? @_docstring "^\"\"\"")
  (#set! injection.language "rst")
  (#set! injection.ignore-first-line-indentation 1)
)
