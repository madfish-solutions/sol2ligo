{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

walk = (root, ctx)->
  switch root.constructor.name
    when "Type_cast"
      if root.target_type.main == "address" and (root.t?.val == "0" or root.t?.val == "0x0")
        ctx.need_burn_address = true
    
    when "Class_decl"
      ctx.scope = "class"
    
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
    scope: ""
  }
  walk root, ctx
  if ctx.need_burn_address
    decl = new ast.Var_decl
    decl.type = new Type "address"
    decl.name = "burn_address"
    root.list.unshift decl
  
  root
