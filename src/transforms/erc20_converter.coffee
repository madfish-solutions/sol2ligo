{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

tx_node = (address_expr, arg_list, name) ->
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  return astBuilder.transaction(arg_list, entrypoint)

callback_tx_node = (address_expr, arg_list, name) ->
  return_callback = astBuilder.self_entrypoint(name + "Callback")
  arg_list.push return_callback
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  return astBuilder.transaction(arg_list, entrypoint)   

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
                return tx_node(root.fn.t, arg_list, "Transfer")
              when "approve"
                return tx_node(root.fn.t, root.arg_list, "Approve")
              when "transferFrom"
                return tx_node(root.fn.t, root.arg_list, "Transfer")
              
              # calls returning values
              when "allowance"
                return callback_tx_node(root.fn.t, root.arg_list, "GetAllowance")
              when "balanceOf"
                return callback_tx_node(root.fn.t, root.arg_list, "GetBalance")
              when "totalSupply"
                return callback_tx_node(root.fn.t, root.arg_list, "GetTotalSupply")
              
  
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