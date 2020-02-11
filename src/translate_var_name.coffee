config = require "./config"
reserved_hash =
  # https://gitlab.com/ligolang/ligo/blob/dev/src/passes/operators/operators.ml
  "get_force"       : true
  "get_chain_id"    : true
  "transaction"     : true
  "get_contract"    : true
  "get_entrypoint"  : true
  "size"            : true
  "int"             : true
  "abs"             : true
  "is_nat"          : true
  "amount"          : true
  "balance"         : true
  "now"             : true
  "unit"            : true
  "source"          : true
  "sender"          : true
  "failwith"        : true
  "bitwise_or"      : true
  "bitwise_and"     : true
  "bitwise_xor"     : true
  "string_concat"   : true
  "string_slice"    : true
  "crypto_check"    : true
  "crypto_hash_key" : true
  "bytes_concat"    : true
  "bytes_slice"     : true
  "bytes_pack"      : true
  "bytes_unpack"    : true
  "set_empty"       : true
  "set_mem"         : true
  "set_add"         : true
  "set_remove"      : true
  "set_iter"        : true
  "set_fold"        : true
  "list_iter"       : true
  "list_fold"       : true
  "list_map"        : true
  "map_iter"        : true
  "map_map"         : true
  "map_fold"        : true
  "map_remove"      : true
  "map_update"      : true
  "map_get"         : true
  "map_mem"         : true
  "sha_256"         : true
  "sha_512"         : true
  "blake2b"         : true
  "cons"            : true
  "EQ"              : true
  "NEQ"             : true
  "NEG"             : true
  "ADD"             : true
  "SUB"             : true
  "TIMES"           : true
  "DIV"             : true
  "MOD"             : true
  "NOT"             : true
  "AND"             : true
  "OR"              : true
  "GT"              : true
  "GE"              : true
  "LT"              : true
  "LE"              : true
  "CONS"            : true
  "address"         : true
  "self_address"    : true
  "implicit_account": true
  "set_delegate"    : true
  "to"              : true
  "args"            : true
  "main"            : true
  # note not reserved, but we don't want collide with types
  
  "map"             : true
  
  # WTF
  "some"            : true
  

reserved_hash[config.contract_storage] = true
reserved_hash[config.op_list] = true

@translate_var_name = (name, ctx)->
  if name[0] == "_"
    name = "#{config.fix_underscore}_"+name
  
  name = name.substr(0,1).toLowerCase() + name.substr 1
  
  if name == "@main"
    "main"
  else if reserved_hash[name] and name != "constructor"
    "#{config.reserved}__#{name}"
  else
    name
