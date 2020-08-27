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
      ctx.foreign_contracts.add root.name 
      ctx.next_gen root, ctx

    else
      ctx.next_gen root, ctx

foreign_calls_to_external = (root, ctx)->
  switch root.constructor.name
    when "Fn_call"
      is_foreign_call = false
      if root.fn.t?.type?.main
        is_foreign_call = ctx.foreign_contracts.has root.fn.t.type.main

      if is_foreign_call
        name = root.fn.name
                        
        contract_type = new Type "contract"
        for arg in root.arg_list
          contract_type.nest_list.push arg.type

        name = astBuilder.string_val("%" + name)

        entrypoint = astBuilder.get_entrypoint(name, root.fn.t, contract_type)

        tx = astBuilder.transaction(root.arg_list, entrypoint)
        return tx
      else
        ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx

@make_calls_external = (root, ctx)->
  full_ctx = {
    walk: collect_local_decls
    next_gen: default_walk
    is_cur_contract_main: false
    foreign_contracts: new Set
  }
  collect_local_decls root, obj_merge(ctx, full_ctx)

  foreign_calls_to_external root, obj_merge(full_ctx, {
    walk: foreign_calls_to_external
    next_gen: default_walk
  })