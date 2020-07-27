module = @
config = require "./config"

@type_generalize = (type)->
  type = "uint"   if config.uint_type_list.has  type
  type = "int"    if config.int_type_list.has   type
  type = "bytes"  if config.bytes_type_list.has type
  type
