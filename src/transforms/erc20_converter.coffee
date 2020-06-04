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

callback_declaration = (name) ->
  cb_decl = new ast.Fn_decl_multiret
  cb_decl.name = name
  
  cb_decl.type_i = new Type "function"
  cb_decl.type_o =  new Type "function"
  
  # TODO proper return arguments types
  cb_decl.arg_name_list.push "action"
  cb_decl.type_i.nest_list.push new Type "uint"

  hint = new ast.Comment
  hint.text = "This method should handle return value of #{name} of foreign contract"
  cb_decl.scope.list.push hint
  return cb_decl

tx_node = (address_expr, arg_list, name, ctx) ->
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  tx = astBuilder.transaction(arg_list, entrypoint)
  op_index = ctx.current_scope_ops_count
  declaration = astBuilder.declaration("op" + op_index, tx, new Type "operation")
  ctx.current_scope_ops_count += 1
  return declaration

callback_tx_node = (address_expr, arg_list, name, ctx) ->
  cb_name = name + "Callback"
  return_callback = astBuilder.self_entrypoint("%" + cb_name)

  if not ctx.callbacks_to_declare.hasOwnProperty cb_name
    cb_decl = callback_declaration(cb_name)
    ctx.callbacks_to_declare[cb_name] = cb_decl


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
      ctx.callbacks_to_declare = {}
      root = ctx.next_gen root, ctx
      for name, decl of ctx.callbacks_to_declare
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