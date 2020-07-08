{ default_walk } = require "./default_walk"
config = require "../config"
Type   = require "type"
ast = require "../ast"
{translate_type} = require "../translate_ligo"

check_external_ops = (scope)->
  if scope.constructor.name == "Scope"
    for v in scope.list
        if v.constructor.name == "Fn_call" and v.fn.constructor.name == "Field_access"
          is_external_call = v.fn.name in ["transfer", "send", "call", "built_in_pure_callback", "delegatecall"]
          return true if is_external_call
        if v.constructor.name == "Scope"
          return true if check_external_ops v
    return false


walk = (root, ctx)->
  {walk} = ctx
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
        if ctx.has_op_list_decl
          inject.val = config.op_list
      root
    
    when "Fn_decl_multiret"
      ctx.state_mutability = root.state_mutability
      
      ctx.returns_op_list  = root.state_mutability not in ['pure', 'view']
      ctx.modifies_storage = root.state_mutability not in ['pure', 'view']
      
      root.scope = walk root.scope, ctx
      ctx.has_op_list_decl = check_external_ops root.scope

      root.returns_op_list  = ctx.returns_op_list
      root.modifies_storage = ctx.modifies_storage
      root.returns_value    = root.type_o.nest_list.length > 0
      
      state_name = config.storage
      state_name = "#{state_name}_#{root.contract_name}" if ctx.contract and ctx.contract != root.contract_name
      if ctx.state_mutability != 'pure'
        root.arg_name_list.unshift config.contract_storage
        root.type_i.nest_list.unshift new Type state_name
      if ctx.modifies_storage
        root.type_o.nest_list.unshift new Type state_name
      if ctx.returns_op_list
        root.type_o.nest_list.unshift new Type "built_in_op_list"
      if root.type_o.nest_list.length == 0
        root.type_o.nest_list.unshift new Type "Unit"

      last = root.scope.list.last()
      if !last or last.constructor.name != "Ret_multi"
        last = new ast.Ret_multi
        last = walk last, ctx
        root.scope.list.push last
      last = root.scope.list.last()
      if last and last.constructor.name == "Ret_multi" and last.t_list.length != root.type_o.nest_list.length
        last = root.scope.list.pop()
        while last.t_list.length > root.type_o.nest_list.length
          last.t_list.pop()
        while root.type_o.nest_list.length > last.t_list.length
          root.type_o.nest_list.pop()
        root.scope.list.push last

      root

    else
      ctx.next_gen root, ctx

@decl_storage_and_oplist_inject = (root, ctx)->
  walk root, obj_merge({walk, next_gen: default_walk})
  
