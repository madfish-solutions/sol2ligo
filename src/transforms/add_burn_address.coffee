{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

need_burn_address = false

do() =>
  walk = (root, ctx)->
    {walk} = ctx
    console.log '==-->', root.constructor.name
    switch root.constructor.name
      when "Var_decl"
        console.log ctx
        need_burn_address = true
        # not finished yet
      when "Scope"
        if ctx.need_burn_address and root.original_node_type == "SourceUnit"
          decl = new ast.Var_decl
          decl.type = new Type "address"
          decl.name = new Type "burn_address"
          # decl.is_const = true
          # decl.assign_value = new ast.Const
          
          root.list[1...1] = [decl]

    ctx.next_gen root, ctx

  @add_burn_address = (root)->
    walk root, {walk, next_gen: default_walk, need_burn_address}
