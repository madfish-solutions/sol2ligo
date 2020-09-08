{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"
{default_var_map_gen} = require "../type_inference/common"
ti_map = default_var_map_gen()

walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Fn_call"
      if ti_map.hasOwnProperty root.fn.name
        return ctx.next_gen root, ctx
      
      if !root.fn_decl
        perr "WARNING (AST transform). no Fn_decl for Fn call named #{root.fn.name}"
        return ctx.next_gen root, ctx
       
      if root.fn_decl.uses_storage
        root.arg_list.unshift storage = new ast.Var
        storage.name = config.contract_storage
        storage.type = new Type config.storage
        storage.name_translate = false

      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx

@call_storage_and_oplist_inject = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)