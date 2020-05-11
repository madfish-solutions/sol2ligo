{ default_walk } = require "./default_walk"
config = require "../config"
Type = require "type"
ast = require "../ast"

walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Fn_call"
      decl = ctx.func_decls[root.fn.name]

      if not decl
        p "can't find declaration for #{root.fn.name}"
      else
        #TODO come up with a better heuristic for detecting if storage should be first argument
        if decl.arg_name_list[0] == config.contract_storage
          root.arg_list.unshift storage = new ast.Var
          storage.name = "self"
          storage.type = new Type config.storage
          storage.name_translate = false

      ctx.next_gen root, ctx
    
    else
      ctx.next_gen root, ctx

@call_storage_and_oplist_inject = (root, ctx)-> 
  walk root, ctx = obj_merge({walk, next_gen: default_walk}, ctx)