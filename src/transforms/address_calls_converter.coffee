{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
astBuilder = require "../ast_builder"

tx_node = (arg_list, cost, address_expr, name, ctx) ->
  entrypoint = astBuilder.foreign_entrypoint(address_expr, name)
  tez_cost = astBuilder.cast_to_tez(cost)
  tx = astBuilder.transaction(arg_list, entrypoint, tez_cost)
  return tx

walk = (root, ctx)->
  switch root.constructor.name
    when "Fn_decl_multiret"
      ctx.current_scope_ops_count = 0
      ctx.next_gen root, ctx

    when "Fn_call"
      if root.fn.t?.type
        switch root.fn.t.type.main
          when "address"
            switch root.fn.name
              when "transfer"
                return tx_node([astBuilder.unit()], root.arg_list[0], root.fn.t, "unit", ctx)
              when "delegatecall"
                return tx_node([astBuilder.unit()], root.arg_list[0], root.fn.t, "unit", ctx)
              when "call"
                return tx_node([astBuilder.unit()], root.arg_list[0], root.fn.t, "unit", ctx)
              when "send"
                return tx_node([astBuilder.unit()], root.arg_list[0], root.fn.t, "unit", ctx)
      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx


@address_calls_converter = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)