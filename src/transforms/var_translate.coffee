{ default_walk } = require "./default_walk"
{translate_var_name} = require "../translate_var_name"
config = require "../config"

do() =>
  walk = (root, ctx)->
    switch root.constructor.name
      when "Var"
        root.name = translate_var_name root.name
        root
      
      when "Var_decl"
        if root.assign_value
          root.assign_value = walk root.assign_value, ctx
        root.name = translate_var_name root.name
        root
      
      when "Var_decl_multi"
        if root.assign_value
          root.assign_value = walk root.assign_value, ctx
        for _var in root.list
          _var.name = translate_var_name _var.name
        root
      
      when "Fn_decl_multiret"
        root.scope = walk root.scope, ctx
        for name,idx in root.arg_name_list
          root.arg_name_list[idx] = translate_var_name name
        root
      
      else
        default_walk root, ctx
      
  @var_translate = (root, ctx) ->
    walk root, {walk, next_gen: default_walk}