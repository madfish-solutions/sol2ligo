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
  address_expr = astBuilder.contract_addr_transform address_expr
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  tx = astBuilder.transaction(arg_list, entrypoint)
  return tx

callback_tx_node = (name, root, ctx) ->
  cb_name = name + "Callback"
  return_callback = astBuilder.self_entrypoint("%" + cb_name)

  if not ctx.callbacks_to_declare_map.has cb_name
    # TODO why are we using nest_list of nest_list?
    return_type = root.fn.type.nest_list[ast.RETURN_VALUES].nest_list[ast.INPUT_ARGS]
    cb_decl = astBuilder.callback_declaration(name, return_type)
    ctx.callbacks_to_declare_map.set cb_name, cb_decl

  arg_list = root.arg_list
  arg_list.push return_callback
  address_expr = astBuilder.contract_addr_transform root.fn.t
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  tx = astBuilder.transaction(arg_list, entrypoint)
  return tx

walk = (root, ctx)->
  switch root.constructor.name
    when "Class_decl"
      # ignore ERC20 interface declaration
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
      
      # collect callback declaration dummies
      ctx.callbacks_to_declare_map = new Map
      root = ctx.next_gen root, ctx
      ctx.callbacks_to_declare_map.forEach (decl)->
        root.scope.list.unshift decl
      return root

    when "Fn_decl_multiret"
      ctx.current_scope_ops_count = 0
      ctx.next_gen root, ctx

    when "Fn_call"
      if root.fn.t?.type
        switch root.fn.t.type.main
          when "struct"
            switch root.fn.name
              when "transfer"
                sender = astBuilder.tezos_var("sender")
                arg_list = root.arg_list
                arg_list.unshift(sender)
                return tx_node(root.fn.t, arg_list, "Transfer", ctx)
              when "approve"
                return tx_node(root.fn.t, root.arg_list, "Approve", ctx)
              when "transferFrom"
                return tx_node(root.fn.t, root.arg_list, "Transfer", ctx)
              
              when "allowance"
                return callback_tx_node("GetAllowance", root,  ctx)
              when "balanceOf"
                return callback_tx_node("GetBalance", root,  ctx)
              when "totalSupply"
                return callback_tx_node("GetTotalSupply", root,  ctx)
              
      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx


@erc20_converter = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)