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
      
      if ctx.should_modify_storage
        root.t_list.unshift inject = new ast.Var
        inject.name = config.contract_storage
        inject.name_translate = false
      
      if ctx.should_ret_op_list
        root.t_list.unshift inject = new ast.Const
        inject.type = new Type "built_in_op_list"
        if ctx.has_op_list_decl
          inject.val = config.op_list
      root

    when "If"
      l = root.t.list.last()
      if l and l.constructor.name == "Ret_multi"
        l = root.t.list.pop()
        root.t.list.push inject = new ast.Fn_call
        inject.fn = new ast.Var
        inject.fn.name = "@respond"
        inject.arg_list = l.t_list[1..]
      f = root.f.list.last()
      if f and f.constructor.name == "Ret_multi"
        f = root.f.list.pop()
        root.f.list.push inject = new ast.Fn_call
        inject.fn = new ast.Var
        inject.fn.name = "@respond"
        inject.arg_list = f.t_list[1..]
      ctx.has_op_list_decl = true
      root
    
    when "Fn_decl_multiret"
      ctx.state_mutability = root.state_mutability
      ctx.should_ret_op_list = root.should_ret_op_list
      ctx.should_modify_storage = root.should_modify_storage
      ctx.should_ret_args = root.should_ret_args
      root.scope = walk root.scope, ctx
      ctx.has_op_list_decl = check_external_ops root.scope
      
      state_name = config.storage
      state_name = "#{state_name}_#{root.contract_name}" if ctx.contract and ctx.contract != root.contract_name
      if !root.should_ret_args and !root.should_modify_storage
        root.arg_name_list.unshift config.receiver_name
        root.type_i.nest_list.unshift contract = new Type "contract" 
        ret_types = []
        for t in root.type_o.nest_list
          ret_types.push translate_type t, ctx
        type = ret_types.join ' * '
        contract.name = config.receiver_name
        contract.val = type
        root.type_o.nest_list = []
        last = root.scope.list.last()
        if last and last.constructor.name == "Ret_multi"
          last = root.scope.list.pop()
          root.scope.list.push inject = new ast.Fn_call
          inject.fn = new ast.Var
          inject.fn.name = "@respond"
          inject.arg_list = last.t_list[1..]
          ctx.has_op_list_decl = true
          last = new ast.Ret_multi
          last = walk last, ctx
          root.scope.list.push last
      if ctx.state_mutability != 'pure'
        root.arg_name_list.unshift config.contract_storage
        root.type_i.nest_list.unshift new Type state_name
      if ctx.should_modify_storage
        root.type_o.nest_list.unshift new Type state_name
      if ctx.should_ret_op_list
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

@contract_storage_fn_decl_fn_call_ret_inject = (root, ctx)->
  walk root, obj_merge({walk, next_gen: default_walk}, ctx)
  
