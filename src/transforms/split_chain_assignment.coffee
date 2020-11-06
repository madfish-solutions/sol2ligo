{ default_walk } = require "./default_walk"
ast = require "../ast"
Type = require "type"

flatten = (list)->
  res_list = []
  for v in list
    if v instanceof Array
      res_list.append flatten v
    else
      res_list.push v
  res_list

array_side_unpack = (res_list, t)->
  if t instanceof Array
    ret = t.pop()
    res_list.append t
    return ret
  t

ret_select = (root, res_list)->
  if res_list.length == 0
    return root
  
  res_list.push root
  res_list

do () =>
  walk = (root, ctx)->
    {walk} = ctx
    switch root.constructor.name
      when "Scope"
        for v, idx in root.list
          root.list[idx] = walk v, ctx
        root.list = flatten root.list
        root
      
      when "Un_op"
        res_list = []
        root.a = array_side_unpack res_list, walk root.a, ctx
        ret_select root, res_list
      
      when "Bin_op"
        res_list = []
        # TODO explicit list
        is_left_to_right = !(root.op in ["ASSIGN"])
        
        if root.op == "ASSIGN"
          ctx_b = clone ctx
          ctx_b.rvalue = true
        else
          ctx_b = ctx
        
        if is_left_to_right
          root.a = array_side_unpack res_list, walk root.a, ctx
          root.b = array_side_unpack res_list, walk root.b, ctx_b
        else
          root.b = array_side_unpack res_list, walk root.b, ctx_b
          root.a = array_side_unpack res_list, walk root.a, ctx
        
        if root.op == "ASSIGN" and ctx.rvalue
          res_list.push root
          root = root.a
        
        ret_select root, res_list
      
      when "Var_decl", "Var_decl_multi"
        res_list = []
        if root.assign_value
          ctx = clone ctx
          ctx.rvalue = true
          root.assign_value = array_side_unpack res_list, walk root.assign_value, ctx
        ret_select root, res_list
      
      when "Field_access", "Throw", "Type_cast"
        res_list = []
        if root.t
          root.t = array_side_unpack res_list, walk root.t, ctx
        ret_select root, res_list
      
      when "Fn_call"
        res_list = []
        root.fn = array_side_unpack res_list, walk root.fn, ctx
        
        for v,idx in root.arg_list
          root.arg_list[idx] = array_side_unpack res_list, walk v, ctx
        
        ret_select root, res_list
      
      when "Struct_init"
        res_list = []
        for v,idx in root.val_list
          root.val_list[idx] = array_side_unpack res_list, walk v, ctx
        
        ret_select root, res_list
      
      when "New"
        res_list = []
        for v,idx in root.arg_list
          root.arg_list[idx] = array_side_unpack res_list, walk v, ctx
        
        ret_select root, res_list
      
      when "Ret_multi"
        res_list = []
        for v,idx in root.t_list
          root.t_list[idx] = array_side_unpack res_list, walk v, ctx
        
        ret_select root, res_list
      
      when "If", "Ternary"
        res_list = []
        root.cond = array_side_unpack res_list, walk root.cond, ctx
        root.t    = array_side_unpack res_list, walk root.t,    ctx
        root.f    = array_side_unpack res_list, walk root.f,    ctx
        # t/f should not be list for If
        
        ret_select root, res_list
      
      when "While"
        res_list = []
        root.cond = array_side_unpack res_list, walk root.cond, ctx
        root.scope= array_side_unpack res_list, walk root.scope,ctx # should not be list
        
        ret_select root, res_list
      
      when "For3"
        res_list = []
        if root.init
          root.init = array_side_unpack res_list, walk root.init, ctx
        if root.cond
          res = walk root.cond, ctx
          if res instanceof Array
            perr "ERROR. chained assignment in for condition is not supported"
          else
            root.cond = res
        if root.iter
          res = walk root.iter, ctx
          if res instanceof Array
            perr "ERROR. chained assignment in for iterator is not supported"
          else
            root.iter = res
        root.scope= walk root.scope, ctx # should not be list
        ret_select root, res_list
      
      when "Tuple", "Array_init"
        res_list = []
        for v,idx in root.list
          root.list[idx] = array_side_unpack res_list, walk v, ctx
        
        ret_select root, res_list
      
      else
        ctx.next_gen root, ctx
  
  @split_chain_assignment = (root, ctx)->
    walk root, {walk, next_gen: default_walk}
