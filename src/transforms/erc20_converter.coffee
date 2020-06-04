{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

# Approximate correspondance of ERC20 to FA1.2 token interface

# totalSupply() returns (uint) -> GetTotalSupply of (unit * contract(amt))
# balanceOf(address tokenOwner) returns (uint balance) -> GetBalance of (address * contract(amt))
# allowance(address tokenOwner, address spender) returns (uint remaining) -> GetAllowance of (address * address * contract(amt))
# transfer(address to, uint tokens) returns (bool success) -> Transfer of (address * address * amt)
# transferFrom(address from, address to, uint tokens) returns (bool success) -> Transfer of (address * address * amt)
# approve(address spender, uint tokens) returns (bool success) -> Approve of (address * amt)

tx_node = (address_expr, arg_list, name, ctx) ->
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  tx = astBuilder.transaction(arg_list, entrypoint)
  op_index = ctx.current_scope_ops_count
  declaration = astBuilder.declaration("op" + op_index, tx, new Type "operation")
  ctx.current_scope_ops_count += 1
  return declaration

callback_tx_node = (address_expr, arg_list, name, ctx) ->
  return_callback = astBuilder.self_entrypoint("%#{name}Callback")
  arg_list.push return_callback
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  tx = astBuilder.transaction(arg_list, entrypoint)
  op_index = ctx.current_scope_ops_count
  declaration = astBuilder.declaration("op" + op_index, tx, new Type "operation")
  ctx.current_scope_ops_count += 1
  return declaration

walk = (root, ctx)->
  switch root.constructor.name
    when "Class_decl"
      for entry in root.scope.list
        if entry.constructor.name == "Fn_decl_multiret"
          switch entry.name
            when "approve",\
                 "totalSupply",\
                 "balanceOf",\ 
                 "allowance",\ 
                 "transfer",\
                 "transferFrom"
              # replace whole class (interface) declaration if we are converting it to FA1.2 anyway
              ret = new ast.Include
              ret.path = "fa1.2.ligo"
              return ret
      ctx.next_gen root, ctx

    when "Fn_decl_multiret"
      ctx.current_scope_ops_count = 0
      ctx.next_gen root, ctx

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
                return tx_node(root.fn.t, arg_list, "Transfer", ctx)
              when "approve"
                return tx_node(root.fn.t, root.arg_list, "Approve", ctx)
              when "transferFrom"
                return tx_node(root.fn.t, root.arg_list, "Transfer", ctx)
              
              when "allowance"
                return callback_tx_node(root.fn.t, root.arg_list, "GetAllowance", ctx)
              when "balanceOf"
                return callback_tx_node(root.fn.t, root.arg_list, "GetBalance", ctx)
              when "totalSupply"
                return callback_tx_node(root.fn.t, root.arg_list, "GetTotalSupply", ctx)
              
      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx


@erc20_converter = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)