{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

walk = (root, ctx)->
  switch root.constructor.name
    when "Var_decl"
      if root.type?.main == "address"
        if root.assign_value?.type
          if root.assign_value.type.main != "address"
            root.assign_value = astBuilder.cast_to_address(root.assign_value)
      ctx.next_gen root, ctx
    
    when "Bin_op"
      if root.op != "INDEX_ACCESS"
        if root.a.type?.main == "address" and \
           root.b.type?.main != "address"
          root.b = astBuilder.cast_to_address(root.b)
        else if root.a.type?.main != "address" and \
           root.b.type?.main == "address"
          root.a = astBuilder.cast_to_address(root.a)

      ctx.next_gen root, ctx
    
    when "Fn_call"
      for arg, idx in root.arg_list
        if root.fn.type?.nest_list[0]?.nest_list[idx]?.main == "address"
          root.arg_list[idx] = astBuilder.cast_to_address(root.arg_list[idx])

      ctx.next_gen root, ctx

    else
      ctx.next_gen root, ctx


@cast_to_address = (root, ctx)-> 
  init_ctx = {
    walk,
    next_gen: default_walk,
  }
  walk root, obj_merge(init_ctx, ctx)