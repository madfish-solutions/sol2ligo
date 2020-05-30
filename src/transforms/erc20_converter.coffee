{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"

create_transaction = (address_expr, input_args, contract_type) ->
  inject = new ast.Fn_call
  inject.fn = new ast.Var
  inject.fn.name = "@transaction"
  inject.arg_list.push params = new ast.Tuple
  params.list = input_args

  inject.arg_list.push tx_cost = new ast.Const
  tx_cost.val = 0
  tx_cost.type = new Type "mutez"

  inject.arg_list.push contract_cast = new ast.Type_cast
  
  contract_cast.target_type = new Type "contract"
  contract_cast.target_type.val = contract_type
  
  get_contract = new ast.Fn_call
  get_contract.type = "function2<function<uint>, function<address>>"
  get_contract.fn = new ast.Var
  get_contract.fn.name = "get_contract"

  get_contract.arg_list.push address_expr

  contract_cast.t = get_contract
  return inject

walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Fn_call"
      if root.fn.t?.type
        switch root.fn.t.type.main
          when "address", "struct"
            switch root.fn.name
              when "transfer"
                sender = new ast.Var
                sender.name = "sender"
                sender.type = new Type "address"
                arg_list = root.arg_list
                arg_list.unshift(sender)
                return create_transaction(root.fn.t, arg_list, "Transfer")
              when "approve"
                return create_transaction(root.fn.t, root.arg_list, "Approve")
              when "transferFrom"
                return create_transaction(root.fn.t, root.arg_list, "Transfer")
              
              # calls returning values
              when "allowance"
                return create_transaction(root.fn.t, root.arg_list, "GetAllowance")
              when "balanceOf"
                return create_transaction(root.fn.t, root.arg_list, "GetBalance")
              when "totalSupply"
                return create_transaction(root.fn.t, root.arg_list, "GetTotalSupply")
              
  
        # totalSupply() returns (uint) -> GetTotalSupply of (unit * contract(amt))
        # balanceOf(address tokenOwner) returns (uint balance) -> GetBalance of (address * contract(amt))
        # allowance(address tokenOwner, address spender) returns (uint remaining) -> GetAllowance of (address * address * contract(amt))
        # transfer(address to, uint tokens) returns (bool success) -> Transfer of (address * address * amt)
        # transferFrom(address from, address to, uint tokens) returns (bool success) -> Transfer of (address * address * amt)
        # approve(address spender, uint tokens) returns (bool success) -> Approve of (address * amt)

      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx

@erc20_converter = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)