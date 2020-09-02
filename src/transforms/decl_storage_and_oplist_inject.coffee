{ default_walk } = require "./default_walk"
config = require "../config"
Type   = require "type"
ast = require "../ast"
{translate_type} = require "../translate_ligo"

walk = (root, ctx)->
  switch root.constructor.name
    when "Ret_multi"
      for v,idx in root.t_list
        root.t_list[idx] = walk v, ctx
      
      if ctx.modifies_storage
        root.t_list.unshift inject = new ast.Var
        inject.name = config.contract_storage
        inject.name_translate = false
      
      if ctx.returns_op_list
        root.t_list.unshift inject = new ast.Const
        inject.type = new Type "built_in_op_list"
        inject.val = config.op_list
      root
    
    when "Fn_decl_multiret"
      ctx.returns_op_list   = root.returns_op_list
      ctx.uses_storage      = root.uses_storage
      ctx.modifies_storage  = root.modifies_storage
      
      root.scope = walk root.scope, ctx
      
      state_name = config.storage
      if root.uses_storage
        root.arg_name_list.unshift config.contract_storage
        root.type_i.nest_list.unshift new Type state_name
      if root.modifies_storage
        root.type_o.nest_list.unshift new Type state_name
      if root.returns_op_list
        root.arg_name_list.unshift config.op_list
        root.type_i.nest_list.unshift new Type "built_in_op_list"
        root.type_o.nest_list.unshift new Type "built_in_op_list"

      last = root.scope.list.last()
      if !last or last.constructor.name != "Ret_multi"
        last = new ast.Ret_multi
        last = walk last, ctx
        root.scope.list.push last
      last = root.scope.list.last()

      root

    else
      ctx.next_gen root, ctx

@decl_storage_and_oplist_inject = (root, ctx)->
  walk root, obj_merge({walk, next_gen: default_walk})
  
