require "fy"
###
TODO rename
  storage           -> storage_type_str
  contract_storage  -> storage_var_name
###
@storage = "state" # type
@contract_storage = "self" # var name
@receiver_name = "receiver" # var name
@callback_address = "callbackAddress" # var name
@default_address = "tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" # const
@burn_address = "tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" # const
@empty_state = "reserved__empty_state" # var name
@op_list = "opList" # var name
@fix_underscore = "fx" # prefix var name
@reserved = "res" # prefix var name
@router_enum = "router_enum"

@int_type_list = ["int"]
for i in [8 .. 256] by 8
  @int_type_list.push "int#{i}"

@uint_type_list = ["uint"]
for i in [8 .. 256] by 8
  @uint_type_list.push "uint#{i}"

@any_int_type_list = []
@any_int_type_list.append @int_type_list
@any_int_type_list.append @uint_type_list

@bytes_type_list = ["bytes"]
for i in [1 .. 32]
  @bytes_type_list.push "bytes#{i}"

# hash versions for o(1) check
@int_type_map = {}
for v in @int_type_list
  @int_type_map[v] = true

@uint_type_map = {}
for v in @uint_type_list
  @uint_type_map[v] = true

@any_int_type_map = {}
for v in @any_int_type_list
  @any_int_type_map[v] = true

@bytes_type_map = {}
for v in @bytes_type_list
  @bytes_type_map[v] = true
