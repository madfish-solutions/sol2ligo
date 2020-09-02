# higher level synthesizers for ast nodes
Type = require "type"
ast = require "./ast"

@unit = () -> 
  unit = new ast.Const
  unit.type  = new Type "Unit"
  unit.val = "unit"
  return unit

@nat_literal = (value) ->
  literal = new ast.Const
  literal.type = new Type "uint"
  literal.val = value
  return literal

@list_init = (array) ->
  init = new ast.Array_init
  init.type = new Type "built_in_op_list"
  init.list = array
  return init

@cast_to_tez = (node) ->
  ret = new ast.Bin_op
  ret.op = "MUL"
  ret.a = node
  ret.b = new ast.Const
  ret.b.val = 1
  ret.b.type = new Type "mutez"
  return ret

@contract_addr_transform = (in_addr_expr)->
  if in_addr_expr.type.main == "struct" and in_addr_expr.arg_list.length == 1
    address_expr = new ast.Type_cast
    address_expr.t = in_addr_expr.arg_list[0]
    address_expr.target_type = new Type "address"
  else
    # fallback
    address_expr = in_addr_expr
  address_expr
  
@transaction = (input_args, entrypoint_expr, cost) ->
  inject = new ast.Fn_call
  inject.fn = new ast.Var
  inject.fn.name = "@transaction"
  inject.arg_list.push params = new ast.Tuple
  params.list = input_args

  if not cost
    cost = new ast.Const
    cost.val = 0
    cost.type = new Type "mutez"
    
  inject.arg_list.push cost
  inject.arg_list.push entrypoint_expr
  
  return inject

@foreign_entrypoint = (address_expr, contract_type) ->
  contract_cast = new ast.Type_cast
  contract_cast.target_type = new Type "contract"
  contract_cast.target_type.val = contract_type
  
  get_contract = new ast.Fn_call
  get_contract.type = "function2<function<uint>, function<address>>"
  get_contract.fn = new ast.Var
  get_contract.fn.name = "@get_contract"

  get_contract.arg_list.push address_expr

  contract_cast.t = get_contract

  return contract_cast

@get_entrypoint = (name, address, type) ->
  contract_cast = new ast.Type_cast
  contract_cast.target_type = type
  
  get_entrypoint = new ast.Fn_call
  get_entrypoint.type = "function2<function<uint>, function<address>>"
  get_entrypoint.fn = new ast.Var
  get_entrypoint.fn.name = "@get_entrypoint"

  get_entrypoint.arg_list.push name
  get_entrypoint.arg_list.push address

  contract_cast.t = get_entrypoint

  return contract_cast


@self_entrypoint = (name, contract_type) ->
  arg = new ast.Var
  arg.name = "@Tezos"

  get_entrypoint = new ast.Fn_call
  get_entrypoint.fn = new ast.Field_access
  get_entrypoint.fn.name = "@self"
  get_entrypoint.fn.t = arg

  entrypoint_name = new ast.Const
  entrypoint_name.type = new Type "string"
  entrypoint_name.val = name

  get_entrypoint.arg_list.push entrypoint_name

  cast = new ast.Type_cast
  cast.t = get_entrypoint
  if not contract_type 
    contract_type = new Type "contract"
    contract_type.val = "unit"
  cast.target_type = contract_type

  return cast

@assignment = (name, rvalue, rtype) ->
  ass = new ast.Bin_op
  ass.op = "ASSIGN"
  ass.a = new ast.Var
  ass.a.name = name
  ass.a.type = rtype

  ass.b = rvalue

  return ass

@declaration = (name, rvalue, rtype) ->
  decl = new ast.Var_decl
  decl.name = name
  decl.type = rtype

  decl.assign_value = rvalue

  return decl

@struct_init = (dict) ->
  structure = new ast.Struct_init
  structure.arg_names = Object.keys(dict)
  structure.val_list = Object.values(dict)
  
  return structure

@callback_declaration = (name, arg_type) ->
  cb_decl = new ast.Fn_decl_multiret
  cb_decl.name = name + "Callback"
  
  cb_decl.type_i = new Type "function"
  cb_decl.type_o =  new Type "function"
  
  cb_decl.arg_name_list.push "arg"
  cb_decl.type_i.nest_list.push arg_type

  # full doc link: https://github.com/madfish-solutions/sol2ligo/wiki/Foreign-contract-callback-stub
  failwith = new ast.Throw
  failwith.t = @string_val "This method should handle return value of #{name} of foreign contract. Read more at https://git.io/JfDxR"
  cb_decl.scope.list.push failwith
  return cb_decl

@tezos_var = (name) ->
  ret = new ast.Field_access
  ret.t = new ast.Var
  ret.t.name = "@Tezos"
  ret.name = "@" + name
  return ret

@enum_val = (name, payload) ->
  # HACK imitate enum value with payload via fn_call
  enum_val = new ast.Fn_call
  enum_val.fn = new ast.Var
  enum_val.fn.name = name
  enum_val.arg_list = payload
  return enum_val

@string_val = (str) ->
  ret = new ast.Const
  ret.type = new Type "string"
  ret.val = str
  return ret

@to_right_comb = (args) ->
  namespace = new ast.Var
  namespace.name = "@Layout"

  call = new ast.Fn_call
  call.fn = new ast.Field_access
  call.fn.name = "convert_to_right_comb"
  call.fn.t = namespace

  call.arg_list = args

  return call

# creates typecast to address if node isn't already address
@cast_to_address = (t)->
  return t if t.type?.main == "address"
  ret = new ast.Type_cast
  ret.target_type = new Type "address"
  ret.t = t
  ret

