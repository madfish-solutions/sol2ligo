{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

need_burn_address = false

do() =>
  walk = (root, ctx)->
    switch root.constructor.name
      when "Type_cast"
        if root.t?.val == "0"
          need_burn_address = true
      
      when "Var_decl"
        if root.type?.main == "address"
          need_burn_address = true
    
    ctx.next_gen root, ctx
  
  @add_burn_address = (root)->
    walk root, {walk, next_gen: default_walk}
    if need_burn_address
      decl = new ast.Var_decl
      decl.type = new Type "address"
      decl.name = "burn_address"
      root.list.unshift decl
    
    root
