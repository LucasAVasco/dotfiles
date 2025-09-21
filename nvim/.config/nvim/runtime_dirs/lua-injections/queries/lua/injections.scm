; extends


; Allows to inject other languages in Lua variables as the following:
;
; -- --[[<language>]]
; local var_name = [[
;   injected file content...
; ]]
;
; Does not work if the injected variable is the first one in a function


; Injection at a variable declaration
(
  (comment
    (comment
      content: (comment_content) @injection.language))
  .
  (variable_declaration
    (assignment_statement
      (expression_list
        value: (string
          content: (string_content) @injection.content ))))
)


; Injection at a generic assignment
(
  (comment
    (comment
      content: (comment_content) @injection.language))
  .
  (assignment_statement
    (expression_list
      value: (string
        content: (string_content) @injection.content )))
)
