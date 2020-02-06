require "fy"
###
TODO rename
  storage           -> storage_type_str
  contract_storage  -> storage_var_name
###
@storage = "state" # type
@contract_storage = "contractStorage" # var name
@callback_address = "callbackAddress" # var name
@default_address = "tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" # const
@empty_state = "reserved__empty_state" # var name
@initialized = "reserved__initialized" # var name
@op_list = "opList" # var name
@fix_underscore = "fx" # prefix var name
@reserved = "reserved" # prefix var name

@int_type_list = ["int"]
for i in [8 .. 256] by 8
  @int_type_list.push "int#{i}"

@uint_type_list = ["uint"]
for i in [8 .. 256] by 8
  @uint_type_list.push "uint#{i}"

@any_int_type_list = []
@any_int_type_list.append @int_type_list
@any_int_type_list.append @uint_type_list

@bytes_type_list = []
for i in [1 .. 32]
  @bytes_type_list.push "bytes#{i}"
