{ default_walk } = require "./default_walk"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"
config = require "../config"

tx_node = (arg_list, cost, address_expr, name, ctx) ->
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  tez_cost = astBuilder.cast_to_tez(cost)
  tx = astBuilder.transaction(arg_list, entrypoint, tez_cost)
  return tx

collect_local_decls = (root, ctx)->
  switch root.constructor.name
    when "Class_decl"
      ctx.is_cur_contract_main = root.is_last
      ctx.next_gen root, ctx

    when "Fn_decl_multiret"
      if ctx.is_cur_contract_main
        ctx.local_fn_decls.add root.name
      ctx.next_gen root, ctx

    else
      ctx.next_gen root, ctx

foreign_calls_to_external = (root, ctx)->
  switch root.constructor.name
    when "Fn_call"
      if not ctx.local_fn_decls.has root.fn.name
        name = root.fn.name
        name = "@" + name[0].toUpperCase() + name.substr 1 
        enum_val = astBuilder.enum_val name, root.arg_list

        contract_type = new Type root.fn.t.name + "_" + config.router_enum

        tx_node([enum_val], astBuilder.nat_literal(0), root.fn.t, contract_type, ctx)
      else
        ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx

@make_calls_external = (root, ctx)->
  full_ctx = {
    walk: collect_local_decls
    next_gen: default_walk
    is_cur_contract_main: false
    local_fn_decls: new Set 
  }
  collect_local_decls root, obj_merge(ctx, full_ctx)

  foreign_calls_to_external root, obj_merge(full_ctx, {
    walk: foreign_calls_to_external
    next_gen: default_walk
  })