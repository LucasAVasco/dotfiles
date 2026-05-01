; Injects shell script in scalars that may represent a shell script
(
  block_mapping_pair
  key: (flow_node) @_key
  value: [
      ; Value is scalar
     (flow_node
       (plain_scalar
         (string_scalar) @injection.content))

     ; Value is sequence (list) of scalars
      (block_node
        (block_sequence
          (block_sequence_item
            (flow_node
              (plain_scalar
                (string_scalar) @injection.content)))))
    ]

  (#any-of? @_key
   "entrypoint" "command" "cmds" "args" "shell" "sh"
   "\"entrypoint\"" "\"command\"" "\"cmds\"" "\"args\"" "\"shell\"" "\"sh\""
   )
  (#set! injection.language "sh")
)

; Injects shell script in scalars blocks that may represent a shell script
(
  block_mapping_pair
  key: (flow_node) @_key
  value: [
      ; Value is a block
      (block_node
        (block_scalar) @injection.content)

      ; Value is a sequence (list) of blocks
      (block_node
        (block_sequence
          (block_sequence_item
            (block_node
              (block_scalar) @injection.content ))))
    ]

  (#any-of? @_key
   "entrypoint" "command" "cmds" "args" "shell" "sh"
   "\"entrypoint\"" "\"command\"" "\"cmds\"" "\"args\"" "\"shell\"" "\"sh\""
   )
  (#offset! @injection.content 0 1 0 0) ; Removes the block delimiter '>', '>-', '|', '|-', etc.
  (#set! injection.language "sh")
)
