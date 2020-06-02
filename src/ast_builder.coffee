# higher level synthesizers for ast nodes
Type = require "type"
ast = require "./ast"

@transaction = (input_args, entrypoint_expr) ->
  inject = new ast.Fn_call
  inject.fn = new ast.Var
  inject.fn.name = "@transaction"
  inject.arg_list.push params = new ast.Tuple
  params.list = input_args

  inject.arg_list.push tx_cost = new ast.Const
  tx_cost.val = 0
  tx_cost.type = new Type "mutez"

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