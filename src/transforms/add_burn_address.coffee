{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

walk = (root, ctx)->
  switch root.constructor.name
    when "Type_cast"
      if root.target_type.main == "address" and root.t
        if +root.t.val == 0
          ctx.need_burn_address = true
        else
          root.t.val = "PLEASE_REPLACE_ETH_ADDRESS_#{root.t.val}_WITH_A_TEZOS_ADDRESS"
          ctx.need_prevent_deploy = true
    
    when "Class_decl"
      ctx.scope = "class"
      if root.is_struct
        for v in root.scope.list
          if v.constructor.name == "Var_decl"
            if v.type?.main == "address"
              ctx.need_burn_address = true
    
    when "Fn_decl_multiret"
      old_scope = ctx.scope
      ctx.scope = "fn"
      root = ctx.next_gen root, ctx
      ctx.scope = old_scope
      return root
    
    when "Var_decl"
      if root.type?.main == "address" and !root.assign_value and ctx.scope == "fn"
        ctx.need_burn_address = true
  
  ctx.next_gen root, ctx

@add_burn_address = (root)->
  ctx = {
    walk,
    next_gen: default_walk,
    need_burn_address: false,
    need_prevent_deploy: false,
    scope: ""
  }
  walk root, ctx
  if ctx.need_burn_address
    decl = new ast.Var_decl
    decl.type = new Type "address"
    decl.name = "burn_address"
    root.list.unshift decl
  
  if ctx.need_prevent_deploy
    root.need_prevent_deploy = true
  
  root
