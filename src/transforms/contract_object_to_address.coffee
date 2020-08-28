{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

walk = (root, ctx)->
  switch root.constructor.name
    when "Class_decl"
      if root.is_contract or root.is_interface
        ctx.known_contracts.add root.name
      ctx.next_gen root, ctx

    when "Var_decl"
      if ctx.known_contracts.has root.type.main
        root.type = new Type "address"
      ctx.next_gen root, ctx

    when "Fn_call"
      if ctx.known_contracts.has root.fn.name
        astBuilder.cast_to_address(root.arg_list[0])
      else
        ctx.next_gen root, ctx

    else
      ctx.next_gen root, ctx


@contract_object_to_address = (root, ctx)-> 
  init_ctx = {
    walk
    next_gen: default_walk
    known_contracts: new Set
  }
  walk root, obj_merge(init_ctx, ctx)