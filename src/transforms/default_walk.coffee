@default_walk = (root, ctx)->
  {walk} = ctx
  switch root.constructor.name
    when "Scope"
      for v, idx in root.list
        root.list[idx] = walk v, ctx
      root
    # ###################################################################################################
    #    expr
    # ###################################################################################################
    when "Var", "Const"
      root
    
    when "Un_op"
      root.a = walk root.a, ctx
      root
    
    when "Bin_op"
      root.a = walk root.a, ctx
      root.b = walk root.b, ctx
      root
    
    when "Field_access"
      root.t = walk root.t, ctx
      root
    
    when "Fn_call"
      for v,idx in root.arg_list
        root.arg_list[idx] = walk v, ctx
      root.fn = walk root.fn, ctx
      root

    when "Struct_init"
      root.fn =  root.fn
      if ctx.class_map and root.arg_names.length == 0
        for v, idx in ctx.class_map[root.fn.name].scope.list
          root.arg_names.push v.name

      for v,idx in root.val_list
        root.val_list[idx] = walk v, ctx
        
      root
    
    when "New"
      for v,idx in root.arg_list
        root.arg_list[idx] = walk v, ctx
      root
    
    # ###################################################################################################
    #    stmt
    # ###################################################################################################
    when "Comment"
      root
    
    when "Continue", "Break"
      root
    
    when "Var_decl"
      if root.assign_value
        root.assign_value = walk root.assign_value, ctx
      root
    
    when "Var_decl_multi"
      if root.assign_value
        root.assign_value = walk root.assign_value, ctx
      root
    
    when "Throw"
      if root.t
        walk root.t, ctx
      root
    
    when "Type_cast"
      walk root.t, ctx
      root

    when "Enum_decl", "PM_switch"
      root
    
    when "Ret_multi"
      for v,idx in root.t_list
        root.t_list[idx] = walk v, ctx
      root
    
    when "If", "Ternary"
      root.cond = walk root.cond, ctx
      root.t    = walk root.t,    ctx
      root.f    = walk root.f,    ctx
      root
    
    when "While"
      root.cond = walk root.cond, ctx
      root.scope= walk root.scope,ctx
      root
    
    when "For3"
      if root.init
        root.init = walk root.init, ctx
      if root.cond
        root.cond = walk root.cond, ctx
      if root.iter
        root.iter = walk root.iter, ctx
      root.scope= walk root.scope, ctx
      root
    
    when "Class_decl"
      root.scope = walk root.scope, ctx
      root
    
    when "Fn_decl_multiret"
      root.scope = walk root.scope, ctx
      root
    
    when "Tuple", "Array_init"
      for v,idx in root.list
        root.list[idx] = walk v, ctx
      root
    
    when "Event_decl"
      root

    when "Include"
      root
    
    else
      ### !pragma coverage-skip-block ###
      perr root
      throw new Error "unknown root.constructor.name #{root.constructor.name}"
