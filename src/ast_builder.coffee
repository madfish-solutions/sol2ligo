# higher level synthesizers for ast nodes
Type = require "type"
ast = require "./ast"

@unit = () -> 
  unit = new ast.Const
  unit.type  = new Type "Unit"
  unit.val = "unit"
  return unit

@cast_to_tez = (node) ->
  ret = new ast.Bin_op
  ret.op = "MUL"
  ret.a = node
  ret.b = new ast.Const
  ret.b.val = 1
  ret.b.type = new Type "mutez"
  return ret

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
  get_contract.fn.name = "get_contract"

  get_contract.arg_list.push address_expr

  contract_cast.t = get_contract

  return contract_cast

@self_entrypoint = (name) ->
  arg = new ast.Var
  arg.name = "Tezos"

  get_entrypoint = new ast.Fn_call
  get_entrypoint.fn = new ast.Field_access
  get_entrypoint.fn.name = "self"
  get_entrypoint.fn.t = arg

  entrypoint_name = new ast.Const
  entrypoint_name.type = new Type "string"
  entrypoint_name.val = name

  get_entrypoint.arg_list.push entrypoint_name
  return get_entrypoint

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